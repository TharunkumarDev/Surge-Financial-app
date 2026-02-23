import admin from 'firebase-admin';
import config from '../config/index.js';

// Initialize Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert({
        projectId: config.firebase.projectId,
        privateKey: config.firebase.privateKey,
        clientEmail: config.firebase.clientEmail,
    }),
});

const db = admin.firestore();
const auth = admin.auth();

export { admin, db, auth };
