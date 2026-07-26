document.addEventListener('DOMContentLoaded', () => {

    // --- Translations ---
    const translations = {
        ar: {
            app_name: "أنا مسلم",
            app_subtitle: "Ana Muslim v1.0.7",
            nav_features: "المميزات",
            nav_quran: "القرآن الكريم",
            nav_azkar: "أذكار المسلم",
            nav_prayer_times: "مواقيت الصلاة",
            nav_screenshots: "صور التطبيق",
            nav_faq: "الأسئلة",
            nav_download: "التحميل والمنصات",
            nav_ios_guide: "دليل الآيفون IPA",
            
            top_announcement_badge: "✨ تحديث جديد v1.0.7",
            top_announcement_text: "🎉 تم إطلاق التحديث 1.0.7! متوفر الآن للآيفون (IPA)، الأندرويد، الكمبيوتر (Windows)، وموقع الويب المباشر بكامل الميزات والأذان.",
            btn_top_ios: "نسخة الآيفون IPA (طريقة التثبيت)",
            btn_top_platforms: "جميع المنصات",
            btn_pdf_doc: "📄 كتيّب ودليل الميزات الشامل (PDF 3 لغات)",
            btn_arch_doc: "📊 تقرير البنية المعمارية والميزات (PDF)",

            hero_badge: "✨ التحديث الجديد v1.0.7 | آيفون IPA، كمبيوتر، أندرويد، وويب!",
            hero_title: "رفيقك اليومي \n في العبادة والحياة",
            hero_desc: "اكتشف تجربة إسلامية متكاملة تجمع بين الجمال والسهولة. متوفر الآن بنسخة الآيفون (IPA 1.0.7)، الأندرويد، الويندوز للكمبيوتر، وتطبيق الويب المباشر بكامل الميزات والأذان.",
            btn_hero_ios: "نسخة الآيفون (iOS IPA 1.0.7)",
            btn_download_apk: "تحميل للأندرويد (APK)",
            btn_hero_desktop: "نسخة الكمبيوتر والويب",
            btn_video: "فيديو تعريفي",
            
            stat_downloads_num: "+100k",
            stat_downloads_label: "تحميل ومستخدم",
            stat_rating_num: "4.9 ★",
            stat_rating_label: "تقييم ممتاز",

            features_subtitle: "لماذا أنا مسلم؟",
            features_title: "كل ما تحتاجه في مكان واحد لجميع أجهزتك",
            feat_quran_title: "القرآن الكريم",
            feat_quran_desc: "المصحف كاملاً بخط واضح، مع تلاوات صوتية لأشهر القراء وإمكانية الحفظ والمتابعة.",
            feat_prayer_title: "مواقيت وأذان دقيق",
            feat_prayer_desc: "تنبيهات دقيقة للأذان حتى عند قفل الشاشة أو إغلاق التطبيق على الآيفون والأندرويد والكمبيوتر.",
            feat_qibla_title: "القبلة الذكية والموقع",
            feat_qibla_desc: "تحديد موقعك الجغرافي باللغة العربية تلقائياً وبوصلة دقيقة 100% لاتجاه القبلة أينما كنت.",
            feat_azkar_title: "أذكار المسلم",
            feat_azkar_desc: "حصن المسلم كاملاً، أذكار الصباح والمساء، وسبحة إلكترونية سلسة تساعدك على الذكر.",
            feat_calendar_title: "التقويم الهجري",
            feat_calendar_desc: "تابع الأيام البيض والمناسبات الدينية مع تقويم هجري وميلادي مدمج في واجهة واحدة.",
            feat_ai_title: "المساعد الذكي",
            feat_ai_desc: "استفسر عن مواقيت الصيام، اتجاه القبلة، أو ابحث في القرآن باستخدام الذكاء الاصطناعي.",

            platform_sec_subtitle: "تغطية شاملة لكل الأجهزة",
            platform_sec_title: "تحميل التطبيق واستخدامه على جميع المنصات",
            platform_sec_desc: "اختر المنصة التي تناسبك واستمتع بنفس التجربة الروحانية الفاخرة",

            card_ios_title: "نسخة الآيفون (iOS IPA)",
            card_ios_desc: "نسخة مخصصة لأجهزة iPhone & iPad بصيغة .ipa تدعم الأذان في الخلفية، الشاشة المقفلة، والإشعارات.",
            btn_ios_card: "تنزيل IPA + طريقة التثبيت",

            card_android_title: "نسخة الأندرويد (APK)",
            card_android_desc: "ملف APK مجاني وبسيط التثبيت لجميع هواتف سامسونج، شاومي، هواوي وبقية أجهزة الأندرويد.",
            btn_android_card: "تحميل ملف APK مجاناً",

            card_win_title: "تطبيق الكمبيوتر (Windows)",
            card_win_desc: "تطبيق مكتبي كامل ونظيف لنظام الويندوز مع تشغيل تلقائي للأذان وتحديد موقعك باللغة العربية.",
            btn_win_card: "تحميل للويندوز (exe / zip)",

            card_web_title: "تطبيق الويب المباشر",
            card_web_desc: "استخدم التطبيق فورياً داخل أي متصفح مع تفعيل إشعارات الأذان الدائمة حتى بعد إغلاق المتصفح.",
            btn_web_card: "فتح تطبيق الويب المباشر",

            screenshots_subtitle: "جولة سريعة",
            screenshots_title: "واجهة عصرية تريح العين",
            quote_verse: "\"أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ\"",
            quote_ref: "سورة الرعد - آية 28",

            faq_title: "الأسئلة الشائعة",
            faq_ios_q: "🍏 كيف أقوم بتثبيت نسخة الآيفون (IPA 1.0.7) على هاتفي؟",
            faq_ios_a: "نظراً لأن النسخة المحدثة بصيغة .ipa وغير متوفرة على App Store حالياً، يمكنك تثبيتها بسهولة وبشكل آمن تماماً عبر كمبيوتر ويندوز أو ماك باستخدام برنامج Sideloadly المجاني بحساب Apple الخاص بك خلال 3 دقائق.",
            btn_faq_ios_guide: "اضغط هنا لمعاينة الشرح التفصيلي بالخطوات",

            faq_q1: "هل التطبيق يعمل بدون إنترنت؟",
            faq_a1: "نعم، معظم الميزات الأساسية مثل قراءة القرآن، الأذكار، والمسبحة تعمل بكفاءة تامة دون الحاجة لاتصال بالإنترنت.",
            faq_q2: "هل التطبيق مجاني؟",
            faq_a2: "التطبيق مجاني 100% لوجه الله تعالى، ولا يحتوي على أي إعلانات مزعجة تعكر صفو العبادة.",
            faq_q3: "كيف أحدد اتجاه القبلة بدقة؟",
            faq_a3: "تأكد من تفعيل خدمة الموقع (GPS) في هاتفك، ثم قم بمعايرة البوصلة بتحريك الهاتف على شكل رقم 8 للحصول على أدق نتيجة.",

            modal_title: "دليل تثبيت تطبيق \"أنا مسلم\" على الآيفون (iOS IPA v1.0.7)",
            modal_subtitle: "خطوات بسيطة وسريعة لتثبيت ملف الـ IPA على هاتف الآيفون أو الآيباد",
            modal_alert: "نظراً لأن النسخة المحدثة v1.0.7 غير متوفرة على App Store حالياً، يمكنك تثبيتها بأمان على هاتفك خلال 3 دقائق باستخدام برنامج Sideloadly وجهاز الكمبيوتر.",
            
            step1_title: "تنزيل ملف التطبيق (Runner.ipa)",
            step1_desc: "قم بتنزيل ملف الـ IPA الخاص بتطبيق \"أنا مسلم\" الإصدار 1.0.7 وحفظه على جهاز الكمبيوتر الخاص بك.",
            btn_step1_dl: "تنزيل ملف Runner.ipa v1.0.7",

            step2_title: "تنزيل وتجهيز برامج Apple على الكمبيوتر (iTunes & iCloud)",
            step2_desc: "تأكد من تنزيل برنامج iTunes وبرنامج iCloud وتثبيتهما على نظام Windows من موقع Apple الرسمي أو متجر Microsoft، ثم سجل دخولك بـ Apple ID الخاص بك.",

            step3_title: "تنزيل برنامج Sideloadly على الكمبيوتر",
            step3_desc: "قم بتنزيل برنامج التثبيت Sideloadly الآمن والمجاني من موقعه الرسمي وتثبيته على جهاز الكمبيوتر (ويندوز أو ماك).",

            step4_title: "توصيل الآيفون وتثبيت الملف",
            step4_desc: "1. وصل الآيفون بالكمبيوتر بكابل USB واضغط وثوق.\n2. افتح Sideloadly واكتب بريد Apple ID.\n3. اسحب واسقط ملف Runner.ipa داخل النافذة.\n4. اضغط Start وانتظر كلمة DONE للتأكيد!",

            step5_title: "توثيق الشهادة على الآيفون (الخطوة الأخيرة)",
            step5_desc: "افتح الآيفون واذهب إلى:\nالإعدادات (Settings) 👈 عام (General) 👈 إدارة الجهاز والـ VPN\nاضغط على إيميلك واضغط (الوثوق). مبارك! افتح التطبيق واستمتع بالأذان والقرآن!",
            btn_close_modal: "إغلاق النافذة",

            footer_privacy: "سياسة الخصوصية",
            footer_contact: "تواصل معنا",
            footer_instagram: "تابعنا على إنستغرام",
            footer_copyright: "© 2026 – تطبيق أنا مسلم. جميع الحقوق محفوظة. Mustafa Alhaj Mustafa",
            footer_disclaimer: "هذا التطبيق لا يقدّم فتاوى شخصية، ويُنصح دائماً بالرجوع إلى أهل العلم."
        },

        en: {
            app_name: "Ana Muslim",
            app_subtitle: "Ana Muslim v1.0.7",
            nav_features: "Features",
            nav_quran: "Noble Quran",
            nav_azkar: "Muslim Azkar",
            nav_prayer_times: "Prayer Times",
            nav_screenshots: "Screenshots",
            nav_faq: "FAQ",
            nav_download: "Downloads & Platforms",
            nav_ios_guide: "iPhone IPA Guide",

            top_announcement_badge: "✨ New Update v1.0.7",
            top_announcement_text: "🎉 Update 1.0.7 Released! Now available for iPhone (IPA), Android (APK), Windows PC, and Live Web App with complete Adhan support.",
            btn_top_ios: "iPhone IPA (Install Guide)",
            btn_top_platforms: "All Platforms",
            btn_pdf_doc: "📄 Master Features Manual (PDF 3 Languages)",
            btn_arch_doc: "📊 Architecture & Features Report (PDF)",

            hero_badge: "✨ New Update v1.0.7 | iPhone IPA, Windows PC, Android & Web!",
            hero_title: "Your Daily Companion \n in Worship & Life",
            hero_desc: "Discover a complete Islamic experience combining elegance and ease. Now available on iPhone (IPA v1.0.7), Android, Windows PC, and Live Web PWA.",
            btn_hero_ios: "iPhone Version (iOS IPA 1.0.7)",
            btn_download_apk: "Download Android (APK)",
            btn_hero_desktop: "PC & Web Versions",
            btn_video: "Intro Video",

            stat_downloads_num: "+100k",
            stat_downloads_label: "Downloads & Users",
            stat_rating_num: "4.9 ★",
            stat_rating_label: "User Rating",

            features_subtitle: "Why Ana Muslim?",
            features_title: "Everything You Need in One Place for All Devices",
            feat_quran_title: "Noble Quran",
            feat_quran_desc: "Complete Quran with clear font, recitations by famous reciters, and progress tracking.",
            feat_prayer_title: "Accurate Adhan & Times",
            feat_prayer_desc: "Precise Adhan notifications even on lock screen and background on iOS, Android, and PC.",
            feat_qibla_title: "Smart Qibla & Location",
            feat_qibla_desc: "Automatic geolocation in Arabic and 100% precise Qibla compass wherever you are.",
            feat_azkar_title: "Muslim Azkar",
            feat_azkar_desc: "Complete Hisn al-Muslim, Morning & Evening Azkar, and smooth digital Tasbih.",
            feat_calendar_title: "Hijri Calendar",
            feat_calendar_desc: "Track White Days and religious events with a combined Hijri & Gregorian calendar.",
            feat_ai_title: "Smart AI Assistant",
            feat_ai_desc: "Ask about fasting times, Qibla direction, or search the Quran using AI.",

            platform_sec_subtitle: "Multi-Platform Support",
            platform_sec_title: "Download & Use App Across All Devices",
            platform_sec_desc: "Choose your platform and enjoy a spiritual experience",

            card_ios_title: "iPhone Version (iOS IPA)",
            card_ios_desc: "Dedicated .ipa version for iPhone & iPad supporting background Adhan, lock screen, and notifications.",
            btn_ios_card: "Download IPA + Install Guide",

            card_android_title: "Android Version (APK)",
            card_android_desc: "Free and easy-to-install APK file for Samsung, Xiaomi, Huawei, and all Android devices.",
            btn_android_card: "Download Free APK",

            card_win_title: "Windows PC App",
            card_win_desc: "Full standalone Windows desktop app with automatic Adhan playback and Arabic geolocation.",
            btn_win_card: "Download for Windows (.exe)",

            card_web_title: "Live Web App (PWA)",
            card_web_desc: "Use the app instantly inside any browser with persistent Web Push Adhan notifications even when closed.",
            btn_web_card: "Open Live Web App",

            screenshots_subtitle: "Quick Tour",
            screenshots_title: "Modern & Comfortable UI",
            quote_verse: "\"Unquestionably, by the remembrance of Allah hearts are assured.\"",
            quote_ref: "Surah Ar-Ra'd - Verse 28",

            faq_title: "Frequently Asked Questions",
            faq_ios_q: "🍏 How do I install the iPhone IPA v1.0.7 version on my phone?",
            faq_ios_a: "Since v1.0.7 is not yet on the App Store, you can easily & safely install it in 3 minutes using Sideloadly and a PC/Mac with your Apple ID.",
            btn_faq_ios_guide: "Click here to view step-by-step guide",

            faq_q1: "Does the app work offline?",
            faq_a1: "Yes, core features like Quran, Azkar, and Tasbih work perfectly without an internet connection.",
            faq_q2: "Is the app free?",
            faq_a2: "The app is 100% free for the sake of Allah, without annoying ads.",
            faq_q3: "How do I get accurate Qibla direction?",
            faq_a3: "Ensure GPS is enabled, then calibrate the compass by moving your phone in a figure-8 motion.",

            modal_title: "Installation Guide for Ana Muslim on iPhone (iOS IPA v1.0.7)",
            modal_subtitle: "Quick & easy steps to install the .ipa file on your iPhone or iPad",
            modal_alert: "Since update v1.0.7 is not yet on the App Store, you can easily & safely install it in 3 minutes using Sideloadly and a PC/Mac.",

            step1_title: "1. Download App File (Runner.ipa)",
            step1_desc: "Download the Ana Muslim v1.0.7 .ipa file and save it on your computer.",
            btn_step1_dl: "Download Runner.ipa v1.0.7",

            step2_title: "2. Install iTunes & iCloud on PC",
            step2_desc: "Download iTunes and iCloud on Windows from Apple or Microsoft Store, then log into your Apple ID.",

            step3_title: "3. Download Sideloadly on PC",
            step3_desc: "Download free & safe Sideloadly installer from sideloadly.io on PC or Mac.",

            step4_title: "4. Connect iPhone & Install IPA",
            step4_desc: "1. Connect iPhone to PC via USB and tap Trust.\n2. Open Sideloadly and type your Apple ID.\n3. Drag and drop Runner.ipa into Sideloadly.\n4. Click Start and wait for DONE!",

            step5_title: "5. Trust Certificate on iPhone (Final Step)",
            step5_desc: "On your iPhone open:\nSettings 👈 General 👈 VPN & Device Management\nTap your Apple ID email and tap Trust.",
            btn_close_modal: "Close Window",

            footer_privacy: "Privacy Policy",
            footer_contact: "Contact Us",
            footer_instagram: "Follow on Instagram",
            footer_copyright: "© 2026 – Ana Muslim App. All rights reserved. Mustafa Alhaj Mustafa",
            footer_disclaimer: "This app does not provide personal Fatwas; always consult scholars."
        },

        fr: {
            app_name: "Ana Muslim",
            app_subtitle: "Ana Muslim v1.0.7",
            nav_features: "Fonctionnalités",
            nav_quran: "Noble Coran",
            nav_azkar: "Adhkar Musulman",
            nav_prayer_times: "Horaires de Prière",
            nav_screenshots: "Captures",
            nav_faq: "FAQ",
            nav_download: "Téléchargements & Plateformes",
            nav_ios_guide: "Guide iPhone IPA",

            top_announcement_badge: "✨ Nouvelle Mise à jour v1.0.7",
            top_announcement_text: "🎉 Mise à jour 1.0.7 lancée ! Disponible pour iPhone (IPA), Android, Windows PC et Web PWA.",
            btn_top_ios: "Version iPhone IPA (Guide)",
            btn_top_platforms: "Toutes les Plateformes",
            btn_pdf_doc: "📄 Manuel des Fonctionnalités (PDF 3 Langues)",
            btn_arch_doc: "📊 Rapport d'Architecture & Fonctions (PDF)",

            hero_badge: "✨ Nouveauté v1.0.7 | iPhone IPA, PC Windows, Android & Web !",
            hero_title: "Votre Compagnon \n Quotidien",
            hero_desc: "Découvrez une expérience islamique complète alliant beauté et simplicité. Disponible sur iPhone (IPA v1.0.7), Android, PC Windows et Web PWA.",
            btn_hero_ios: "Version iPhone (iOS IPA 1.0.7)",
            btn_download_apk: "Télécharger Android (APK)",
            btn_hero_desktop: "Versions PC & Web",
            btn_video: "Vidéo Intro",

            stat_downloads_num: "+100k",
            stat_downloads_label: "Téléchargements & Utilisateurs",
            stat_rating_num: "4.9 ★",
            stat_rating_label: "Note Utilisateurs",

            features_subtitle: "Pourquoi Ana Muslim ?",
            features_title: "Tout ce dont vous avez besoin pour tous vos appareils",
            feat_quran_title: "Noble Coran",
            feat_quran_desc: "Coran complet, police claire, récitations audio et suivi de progression.",
            feat_prayer_title: "Horaires & Adhan Précis",
            feat_prayer_desc: "Notifications Adhan précises sur écran verrouillé et arrière-plan sur iOS, Android et PC.",
            feat_qibla_title: "Qibla Intelligente & Localisation",
            feat_qibla_desc: "Géolocalisation automatique en arabe et boussole Qibla 100% précise.",
            feat_azkar_title: "Adhkar Musulman",
            feat_azkar_desc: "Hisn al-Muslim complet, Adhkar du matin/soir et Tasbih numérique fluide.",
            feat_calendar_title: "Calendrier Hégirien",
            feat_calendar_desc: "Suivez les jours blancs et occasions religieuses avec un calendrier Hégirien/Grégorien.",
            feat_ai_title: "Assistant IA Intelligent",
            feat_ai_desc: "Demandez les heures de jeûne, la Qibla ou recherchez dans le Coran via l'IA.",

            platform_sec_subtitle: "Support Multi-Plateforme",
            platform_sec_title: "Téléchargez l'App sur Tous vos Appareils",
            platform_sec_desc: "Choisissez votre plateforme et vivez une expérience spirituelle unique",

            card_ios_title: "Version iPhone (iOS IPA)",
            card_ios_desc: "Version .ipa dédiée pour iPhone & iPad avec Adhan en arrière-plan et écran verrouillé.",
            btn_ios_card: "Télécharger IPA + Guide",

            card_android_title: "Version Android (APK)",
            card_android_desc: "Fichier APK gratuit et facile à installer pour Samsung, Xiaomi, Huawei et tout Android.",
            btn_android_card: "Télécharger APK Gratuit",

            card_win_title: "App PC (Windows)",
            card_win_desc: "App PC autonome pour Windows avec Adhan automatique et géolocalisation en arabe.",
            btn_win_card: "Télécharger pour Windows (.exe)",

            card_web_title: "App Web en Direct (PWA)",
            card_web_desc: "Utilisez l'app instantanément dans tout navigateur avec notifications Adhan permanentes.",
            btn_web_card: "Ouvrir l'App Web",

            screenshots_subtitle: "Tour Rapide",
            screenshots_title: "Interface Moderne & Confortable",
            quote_verse: "\"N'est-ce point par l'évocation d'Allah que se tranquillisent les cœurs ?\"",
            quote_ref: "Sourate Ar-Ra'd - Verset 28",

            faq_title: "Questions Fréquentes",
            faq_ios_q: "🍏 Comment installer la version iPhone IPA v1.0.7 ?",
            faq_ios_a: "Comme la v1.0.7 n'est pas encore sur l'App Store, vous pouvez l'installer en 3 minutes via Sideloadly et un PC.",
            btn_faq_ios_guide: "Cliquez ici pour voir le guide détaillé",

            faq_q1: "L'application fonctionne-t-elle hors ligne ?",
            faq_a1: "Oui, la plupart des fonctions (Coran, Adhkar, Tasbih) fonctionnent parfaitement sans internet.",
            faq_q2: "L'application est-elle payante ?",
            faq_a2: "L'application est 100% gratuite pour la face d'Allah, sans publicités.",
            faq_q3: "Comment avoir une Qibla précise ?",
            faq_a3: "Activez le GPS et calibrez la boussole en faisant un 8 avec votre téléphone.",

            modal_title: "Guide d'installation pour Ana Muslim sur iPhone (iOS IPA v1.0.7)",
            modal_subtitle: "Étapes simples pour installer le fichier .ipa sur votre iPhone ou iPad",
            modal_alert: "Comme la v1.0.7 n'est pas encore sur l'App Store, vous pouvez l'installer en 3 minutes via Sideloadly et un PC.",

            step1_title: "1. Télécharger Fichier App (Runner.ipa)",
            step1_desc: "Téléchargez le fichier Runner.ipa v1.0.7 et enregistrez-le sur votre ordinateur.",
            btn_step1_dl: "Télécharger Runner.ipa v1.0.7",

            step2_title: "2. Installer iTunes & iCloud sur PC",
            step2_desc: "Téléchargez iTunes et iCloud sur Windows, puis connectez-vous à votre Apple ID.",

            step3_title: "3. Télécharger Sideloadly sur PC",
            step3_desc: "Téléchargez Sideloadly gratuitement depuis sideloadly.io sur PC ou Mac.",

            step4_title: "4. Connecter iPhone & Installer",
            step4_desc: "1. Connectez l'iPhone au PC par USB.\n2. Ouvrez Sideloadly et entrez votre Apple ID.\n3. Glissez-déposez Runner.ipa.\n4. Cliquez sur Start jusqu'à voir DONE !",

            step5_title: "5. Approuver le Certificat sur iPhone",
            step5_desc: "Sur iPhone allez dans :\nRéglages 👈 Général 👈 Gestion des appareils et VPN\nAppuyez sur votre e-mail et choisissez Faire confiance.",
            btn_close_modal: "Fermer la fenêtre",

            footer_privacy: "Politique de confidentialité",
            footer_contact: "Contactez-nous",
            footer_instagram: "Suivre sur Instagram",
            footer_copyright: "© 2026 – Application Ana Muslim. Tous droits réservés.",
            footer_disclaimer: "Cette application ne fournit pas de Fatwas personnelles; consultez les savants."
        }
    };

    // --- Language Change Function ---
    const langSelector = document.getElementById('language-selector');
    if (langSelector) {
        langSelector.addEventListener('change', (e) => {
            setLanguage(e.target.value);
        });
    }

    function setLanguage(lang) {
        const dict = translations[lang] || translations.ar;
        document.documentElement.lang = lang;
        document.documentElement.dir = (lang === 'ar') ? 'rtl' : 'ltr';

        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (dict[key]) {
                if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
                    el.placeholder = dict[key];
                } else {
                    // Preserve icon if present
                    const icon = el.querySelector('i');
                    if (icon) {
                        const iconHTML = icon.outerHTML;
                        el.innerHTML = iconHTML + ' ' + dict[key];
                    } else {
                        el.innerText = dict[key];
                    }
                }
            }
        });
    }

    // Initialize with default or saved language
    const savedLang = localStorage.getItem('anamuslim_lang') || 'ar';
    if (langSelector) langSelector.value = savedLang;
    setLanguage(savedLang);

    if (langSelector) {
        langSelector.addEventListener('change', (e) => {
            localStorage.setItem('anamuslim_lang', e.target.value);
        });
    }

    // --- Scroll & Reveal ---
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('active');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));

    // Navbar scroll
    const header = document.querySelector('.header');
    if (header) {
        window.addEventListener('scroll', () => { header.classList.toggle('scrolled', window.scrollY > 50); });
    }

    // FAQ Accordions
    document.querySelectorAll('.accordion-header').forEach(header => {
        header.addEventListener('click', () => {
            const content = header.nextElementSibling;
            const isOpen = header.classList.contains('active');

            // Close others
            document.querySelectorAll('.accordion-header').forEach(h => {
                if (h !== header && h.classList.contains('active')) {
                    h.classList.remove('active');
                    h.nextElementSibling.style.maxHeight = null;
                    h.nextElementSibling.style.opacity = '0';
                }
            });

            // Toggle current
            header.classList.toggle('active');
            if (!isOpen) {
                content.style.opacity = '1';
                requestAnimationFrame(() => {
                    content.style.maxHeight = (content.scrollHeight + 30) + "px";
                });
            } else {
                content.style.maxHeight = null;
                content.style.opacity = '0';
            }
        });
    });

    // --- 3D Tilt for Cards ---
    const tiltCards = document.querySelectorAll('[data-tilt], .feature-card, .platform-card');
    tiltCards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            const centerX = rect.width / 2;
            const centerY = rect.height / 2;

            const rotateX = ((y - centerY) / centerY) * -5;
            const rotateY = ((x - centerX) / centerX) * 5;

            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.02)`;
        });

        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale(1)';
        });
    });

    // --- Custom Cursor Logic ---
    const cursorDot = document.querySelector('[data-cursor-dot]');
    const cursorOutline = document.querySelector('[data-cursor-outline]');

    if (cursorDot && cursorOutline) {
        window.addEventListener('mousemove', function (e) {
            const posX = e.clientX;
            const posY = e.clientY;

            cursorDot.style.left = `${posX}px`;
            cursorDot.style.top = `${posY}px`;

            cursorOutline.animate({
                left: `${posX}px`,
                top: `${posY}px`
            }, { duration: 500, fill: "forwards" });
        });

        const hoverables = document.querySelectorAll('a, button, .feature-card, .platform-card, .accordion-header');
        hoverables.forEach(el => {
            el.addEventListener('mouseenter', () => {
                cursorOutline.style.width = '60px';
                cursorOutline.style.height = '60px';
                cursorOutline.style.backgroundColor = 'rgba(255,255,255,0.1)';
            });
            el.addEventListener('mouseleave', () => {
                cursorOutline.style.width = '40px';
                cursorOutline.style.height = '40px';
                cursorOutline.style.backgroundColor = 'transparent';
            });
        });
    }

    // --- Mobile Menu Logic ---
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const closeMenuBtn = document.querySelector('.close-menu-btn');
    const mobileMenu = document.querySelector('.mobile-menu');
    const mobileLinks = document.querySelectorAll('.mobile-nav-links a');

    if (mobileMenuBtn && mobileMenu) {
        mobileMenuBtn.addEventListener('click', () => {
            mobileMenu.classList.add('active');
            document.body.style.overflow = 'hidden';
        });

        const closeMenu = () => {
            mobileMenu.classList.remove('active');
            document.body.style.overflow = '';
        };

        if (closeMenuBtn) closeMenuBtn.addEventListener('click', closeMenu);
        mobileLinks.forEach(link => {
            link.addEventListener('click', closeMenu);
        });
    }

});

// --- Global iOS IPA Modal Helper Functions ---
function openIosModal(e) {
    if (e) e.preventDefault();
    const modal = document.getElementById('ios-modal');
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeIosModal() {
    const modal = document.getElementById('ios-modal');
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }
}

function closeAnnouncementBar() {
    const bar = document.getElementById('announcement-bar');
    if (bar) {
        bar.style.display = 'none';
    }
}

// Close on outside click & ESC key
document.addEventListener('click', (e) => {
    const modal = document.getElementById('ios-modal');
    if (modal && e.target === modal) {
        closeIosModal();
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeIosModal();
    }
});
