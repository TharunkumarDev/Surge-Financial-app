import dotenv from 'dotenv';
dotenv.config();

export const config = {
    port: process.env.PORT || 3000,
    nodeEnv: process.env.NODE_ENV || 'development',

    firebase: {
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    },

    openai: {
        apiKey: process.env.OPENAI_API_KEY,
        model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
        maxTokens: parseInt(process.env.OPENAI_MAX_TOKENS || '200'),
        temperature: parseFloat(process.env.OPENAI_TEMPERATURE || '0.7'),
    },

    redis: {
        url: process.env.REDIS_URL || 'redis://localhost:6379',
    },

    rateLimits: {
        free: {
            daily: parseInt(process.env.RATE_LIMIT_FREE_DAILY || '5'),
            perMinute: parseInt(process.env.RATE_LIMIT_FREE_PER_MINUTE || '1'),
        },
        pro: {
            daily: parseInt(process.env.RATE_LIMIT_PRO_DAILY || '100'),
            perMinute: parseInt(process.env.RATE_LIMIT_PRO_PER_MINUTE || '10'),
        },
    },

    cors: {
        origin: process.env.CORS_ORIGIN || '*',
    },

    logging: {
        level: process.env.LOG_LEVEL || 'info',
    },
};

// Validate required config
const requiredEnvVars = [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_PRIVATE_KEY',
    'FIREBASE_CLIENT_EMAIL',
    'OPENAI_API_KEY',
];

for (const envVar of requiredEnvVars) {
    if (!process.env[envVar]) {
        console.error(`❌ Missing required environment variable: ${envVar}`);
        process.exit(1);
    }
}

export default config;
