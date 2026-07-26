// Firebase Cloud Messaging Web Push Service Worker
// Enables Web Notifications even when the website tab/page is CLOSED.

importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBfIAz7R5ChtM5QgMkr-KpHCIhtrjv1KK4",
  authDomain: "anamuslim-app.firebaseapp.com",
  projectId: "anamuslim-app",
  storageBucket: "anamuslim-app.appspot.com",
  messagingSenderId: "1055743454746",
  appId: "1:1055743454746:web:anamuslimweb"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification ? payload.notification.title : 'إشعار من تطبيق أنا مسلم 🌙';
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : 'حان الآن موعد الصلاة - الله أكبر',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
    requireInteraction: true
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
