import { createClient } from 'redis';
import config from '../config/index.js';
import { db } from '../config/firebase.js';

let redisClient;

// Initialize Redis client
async function initRedis() {
    redisClient = createClient({
        url: config.redis.url,
    });

    redisClient.on('error', (err) => console.error('Redis Client Error', err));

    await redisClient.connect();
    console.log('✅ Redis connected');
}

initRedis().catch(console.error);

/**
 * Rate limiting middleware with Redis storage
 * Enforces per-user daily and per-minute limits based on subscription tier
 */
export async function rateLimiter(req, res, next) {
    try {
        const userId = req.user.uid;

        // Get user's subscription tier from Firestore
        const userDoc = await db.collection('users').doc(userId).get();
        const userData = userDoc.data();
        const isPro = userData?.subscriptionTier === 'pro';

        // Get rate limits based on tier
        const limits = isPro ? config.rateLimits.pro : config.rateLimits.free;

        // Check daily limit
        const dailyKey = `rate:daily:${userId}`;
        const dailyCount = await redisClient.get(dailyKey);

        if (dailyCount && parseInt(dailyCount) >= limits.daily) {
            const ttl = await redisClient.ttl(dailyKey);
            const hoursRemaining = Math.ceil(ttl / 3600);

            return res.status(429).json({
                error: isPro
                    ? `Daily limit reached. Try again in ${hoursRemaining} hours.`
                    : `You've used all ${limits.daily} AI chats today. Upgrade to Pro for unlimited conversations! 🚀`,
                retryAfter: ttl,
                upgradePrompt: !isPro,
            });
        }

        // Check per-minute limit
        const minuteKey = `rate:minute:${userId}`;
        const minuteCount = await redisClient.get(minuteKey);

        if (minuteCount && parseInt(minuteCount) >= limits.perMinute) {
            return res.status(429).json({
                error: 'Too many requests. Please wait a moment.',
                retryAfter: 60,
            });
        }

        // Increment counters
        await redisClient.incr(dailyKey);
        await redisClient.expire(dailyKey, 86400); // 24 hours

        await redisClient.incr(minuteKey);
        await redisClient.expire(minuteKey, 60); // 1 minute

        // Add usage info to response headers
        res.setHeader('X-RateLimit-Limit-Daily', limits.daily);
        res.setHeader('X-RateLimit-Remaining-Daily', Math.max(0, limits.daily - (parseInt(dailyCount) || 0) - 1));
        res.setHeader('X-RateLimit-Tier', isPro ? 'pro' : 'free');

        next();
    } catch (error) {
        console.error('Rate limiter error:', error);
        // Fail open - don't block requests if rate limiter fails
        next();
    }
}

export { redisClient };
