/**
 * Firebase Cloud Functions لنظام الإشعارات اليومية المؤتمتة والمزودة بالذكاء الاصطناعي لتطبيق أنا مسلم
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const https = require('https');
admin.initializeApp();

const db = admin.firestore();

// مفتاح Gemini API المشفر للخدمات السحابية
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || 'AIzaSyBfIAz7R5ChtM5QgMkr-KpHCIhtrjv1KK4';

/**
 * دالة سريعة لاستدعاء Google Gemini AI لتوليد إشعار إسلامي متجدد
 */
async function generateAINotification(topicType) {
  return new Promise((resolve, reject) => {
    let prompt = 'اصنع إشعاراً إسلامياً مشوقاً وقصيراً جداً لـ آية قرآنية مع تفسير وتأمل إيماني ملهم في سطرين.';
    if (topicType === 'hadith') {
      prompt = 'اصنع إشعاراً إسلامياً مشوقاً وقصيراً جداً لـ حديث نبوي صحيح مع فضل العمل به في سطرين.';
    } else if (topicType === 'dhikr') {
      prompt = 'اصنع إشعاراً إسلامياً مشوقاً وقصيراً جداً لـ ذكر أو دعاء مأثور مع الأجر والفضل في سطرين.';
    }

    const payload = JSON.stringify({
      contents: [
        {
          parts: [
            { text: `أنت محرر تطبيقات إسلامية. ${prompt} اجعل الرد بصيغة JSON فقط بهذا الشكل بالضبط: {"title": "العنوان مع إيموجي", "body": "نص الإشعار المشوق", "deep_link": "/quran"}` }
          ]
        }
      ]
    });

    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          if (json.candidates && json.candidates[0] && json.candidates[0].content) {
            const rawText = json.candidates[0].content.parts[0].text;
            const cleanedText = rawText.replace(/```json|```/g, '').trim();
            const parsed = JSON.parse(cleanedText);
            resolve(parsed);
          } else {
            resolve(null);
          }
        } catch (e) {
          console.error('Failed to parse AI response:', e);
          resolve(null);
        }
      });
    });

    req.on('error', (e) => {
      console.error('Gemini HTTPS error:', e);
      resolve(null);
    });

    req.write(payload);
    req.end();
  });
}

/**
 * 1. دالة مجدولة يومياً لإرسال المحتوى الذكي المؤتمت (AI-Powered Scheduled Push)
 * تعمل يومياً الساعة 08:00 صباحاً بتوقيت مكة المكرمة
 */
exports.sendDailyContentScheduled = functions.pubsub
    .schedule('0 8 * * *')
    .timeZone('Asia/Riyadh')
    .onRun(async (context) => {
      const todayStr = new Date().toISOString().split('T')[0];
      console.log(`Starting AI-powered daily push for date: ${todayStr}`);

      try {
        // 1. فحص وجود وثيقة محددة يدوياً من Firestore
        const snapshot = await db.collection('daily_notifications')
            .where('publish_date', '==', todayStr)
            .where('is_published', '==', true)
            .get();

        if (!snapshot.empty) {
          for (const doc of snapshot.docs) {
            const data = doc.data();
            const category = data.category || 'daily_quran';
            const contentAr = data.content && data.content.ar ? data.content.ar : {};
            const title = contentAr.title || 'آية اليوم 📖';
            const body = contentAr.body || '';
            const deepLink = data.deep_link || '/quran';

            let topicName = 'topic_ar_daily_quran';
            if (category === 'daily_hadith') topicName = 'topic_ar_daily_hadith';
            if (category === 'daily_dhikr') topicName = 'topic_ar_daily_dhikr';

            const message = {
              notification: { title, body },
              data: { category, deep_link: deepLink, notification_id: doc.id },
              topic: topicName,
            };

            const response = await admin.messaging().send(message);
            console.log(`Sent manual notification to topic ${topicName}:`, response);
          }
          return null;
        }

        // 2. إذا لم يحدد المشرف محتوى يدوياً اليوم، يقوم الذكاء الاصطناعي بتوليد آية وتأمل متجدد تلقائياً!
        console.log('No manual content found for today. Generating via Gemini AI...');
        const aiContent = await generateAINotification('quran');

        const title = aiContent ? aiContent.title : 'آية اليوم وتأمل إيماني 📖';
        const body = aiContent ? aiContent.body : '﴿وَقُلْ رَبِّ زِدْنِي عِلْمًا﴾ - ابدأ يومك بذكر الله وتأمل آياته العظيمة.';
        const deepLink = aiContent ? aiContent.deep_link : '/quran';
        const topicName = 'topic_ar_daily_quran';

        const message = {
          notification: { title, body },
          data: { category: 'daily_quran', deep_link: deepLink, generated_by: 'gemini_ai' },
          topic: topicName,
        };

        const response = await admin.messaging().send(message);
        console.log(`Successfully sent AI-generated push to topic ${topicName}:`, response);

        // تسجيل العملية في السجلات
        await db.collection('notification_logs').add({
          category: 'daily_quran',
          topic: topicName,
          title: title,
          body: body,
          sent_at: admin.firestore.FieldValue.serverTimestamp(),
          status: 'success',
          generated_by: 'gemini_ai',
          fcm_message_id: response,
        });

      } catch (error) {
        console.error('Error sending scheduled AI notifications:', error);
      }

      return null;
    });

/**
 * 2. دالة أسبوعية لتنظيف التوكينات المعطلة والمنتهية من قاعدة البيانات
 */
exports.cleanupInvalidTokens = functions.pubsub
    .schedule('0 3 * * 0')
    .timeZone('Asia/Riyadh')
    .onRun(async (context) => {
      console.log('Starting weekly inactive token cleanup...');
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const snapshot = await db.collection('user_devices')
          .where('last_active_at', '<', thirtyDaysAgo)
          .get();

      let count = 0;
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        count++;
      });

      await batch.commit();
      console.log(`Cleaned up ${count} inactive user device tokens.`);
      return null;
    });

/**
 * 3. دالة إرسال يدوي من شاشة الأدمن في التطبيق
 * تستقبل العنوان والنص والموضوع وتبعث الإشعار لكل المشتركين
 */
exports.sendManualNotification = functions.https.onCall(async (data, context) => {
  // البيانات المرسلة من التطبيق
  const title = data.title;
  const body = data.body;
  const topic = data.topic || 'topic_announcements';
  const category = data.category || 'announcement';
  const deepLink = data.deep_link || '';

  // تحقق من وجود البيانات المطلوبة
  if (!title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'العنوان والنص مطلوبان'
    );
  }

  try {
    // إرسال الإشعار عبر FCM لكل المشتركين في الموضوع
    const message = {
      notification: { title, body },
      data: {
        category: category,
        deep_link: deepLink,
        sent_by: 'admin_manual',
      },
      topic: topic,
    };

    const response = await admin.messaging().send(message);
    console.log(`Admin manual push sent to topic ${topic}:`, response);

    // تسجيل العملية في السجلات
    await db.collection('notification_logs').add({
      category: category,
      topic: topic,
      title: title,
      body: body,
      deep_link: deepLink,
      sent_at: admin.firestore.FieldValue.serverTimestamp(),
      status: 'success',
      sent_by: 'admin_manual',
      fcm_message_id: response,
    });

    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending manual notification:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * 4. دالة إرسال يدوي عبر HTTP POST مباشرة من لوحة الأدمن في التطبيق
 */
exports.sendManualNotificationHttp = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ success: false, error: 'Method Not Allowed' });
    return;
  }

  const { title, body, topic, category, deep_link, admin_secret } = req.body || {};

  if (admin_secret !== '2003' && admin_secret !== '77459b9b941bcb4714d0c121313c900ecf30541d158eb2b9b178cdb8eca6457e') {
    res.status(401).json({ success: false, error: 'غير مصرح: كلمة مرور الأدمن غير صحيحة' });
    return;
  }

  if (!title || !body) {
    res.status(400).json({ success: false, error: 'العنوان والنص مطلوبان' });
    return;
  }

  try {
    const targetTopic = topic || 'topic_announcements';
    const message = {
      notification: { title, body },
      data: {
        category: category || 'announcement',
        deep_link: deep_link || '',
        sent_by: 'admin_app_direct',
      },
      topic: targetTopic,
    };

    const response = await admin.messaging().send(message);
    console.log(`HTTP Admin push sent to topic ${targetTopic}:`, response);

    await db.collection('notification_logs').add({
      category: category || 'announcement',
      topic: targetTopic,
      title: title,
      body: body,
      deep_link: deep_link || '',
      sent_at: admin.firestore.FieldValue.serverTimestamp(),
      status: 'success',
      sent_by: 'admin_app_direct',
      fcm_message_id: response,
    });

    res.status(200).json({ success: true, messageId: response });
  } catch (error) {
    console.error('Error sending HTTP admin notification:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

