importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

if (!firebase.apps.length) {
   firebase.initializeApp({
     apiKey: 'AIzaSyAmw1PjLK82peDwBi-a1pxLSBLYkXnXHPk',
     appId: '1:191908340162:web:b7d897f1db846fe018b65b',
     messagingSenderId: '191908340162',
     projectId: 'olrrooms-1c565',
     authDomain: 'olrrooms-1c565.firebaseapp.com',
     storageBucket: 'olrrooms-1c565.appspot.com',
     measurementId: 'G-3RXQNZ79RW',
   });
   console.log("If Firebase JS");
}else {
   firebase.app(); // if already initialized, use that one
   console.log("Else Firebase JS");
}


// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
});