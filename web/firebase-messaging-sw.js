// Firebase Cloud Messaging Service Worker
// This file must be in the /web directory and is required for background notifications on web.

importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCTnBSfvwg2oP_4KLiFKSzQzRmLUaatUmk',
  authDomain: 'skillswap-887cc.firebaseapp.com',
  projectId: 'skillswap-887cc',
  storageBucket: 'skillswap-887cc.firebasestorage.app',
  messagingSenderId: '595666774474',
  appId: '1:595666774474:web:99df527e3acdf1932b0733',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);

  const { title, body, icon } = payload.notification ?? {};

  self.registration.showNotification(title ?? 'SkillSwap', {
    body: body ?? '',
    icon: icon ?? '/icons/Icon-192.png',
  });
});
