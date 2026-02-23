import { auth } from '../config/firebase.js';

/**
 * Middleware to verify Firebase ID token
 * Attaches decoded user info to req.user
 */
export async function verifyFirebaseToken(req, res, next) {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                error: 'Authentication required. Please sign in.',
            });
        }

        const idToken = authHeader.split('Bearer ')[1];

        // Verify the ID token
        const decodedToken = await auth.verifyIdToken(idToken);

        // Attach user info to request
        req.user = {
            uid: decodedToken.uid,
            email: decodedToken.email,
        };

        next();
    } catch (error) {
        console.error('Token verification failed:', error.message);

        return res.status(401).json({
            error: 'Authentication failed. Please sign in again.',
        });
    }
}
