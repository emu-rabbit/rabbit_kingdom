// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.5.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.5.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBik9H1oZPI42gYmoM0fX9Q9kzOzBqHfRY",
  authDomain: 'rabbit-kingdom-2759a.firebaseapp.com',
  projectId: 'rabbit-kingdom-2759a',
  messagingSenderId: "689030757641",
  appId: '1:689030757641:web:fe66dc39be5fb4fea4e7d8',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] 背景收到推播: ', payload);
  const title = payload.notification.title;
  const options = {
    body: payload.notification.body,
    icon: '/icon.png',
  };
  self.registration.showNotification(title, options);
});
