import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import config from './config/index.js';
import surgeAIRoutes from './routes/surge-ai.js';
import { openaiClient } from './services/openai-client.js';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
    origin: config.cors.origin,
    credentials: true,
}));

// Body parsing
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// Request logging (development only)
if (config.nodeEnv === 'development') {
    app.use((req, res, next) => {
        console.log(`${req.method} ${req.path}`);
        next();
    });
}

// Routes
app.use('/api/v1/surge-ai', surgeAIRoutes);

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        service: 'Surge AI Gateway',
        version: '1.0.0',
        status: 'running',
        endpoints: {
            chat: 'POST /api/v1/surge-ai/chat',
            health: 'GET /api/v1/surge-ai/health',
            usage: 'GET /api/v1/surge-ai/usage',
        },
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Endpoint not found',
        path: req.path,
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);

    res.status(500).json({
        error: 'Internal server error',
        message: config.nodeEnv === 'development' ? err.message : undefined,
    });
});

// Start server
async function startServer() {
    try {
        // Check OpenAI connection
        const isOpenAIUp = await openaiClient.healthCheck();

        if (!isOpenAIUp) {
            console.warn('⚠️  Warning: OpenAI API is not accessible');
            console.warn('   Check your OPENAI_API_KEY environment variable');
        } else {
            console.log('✅ OpenAI API connected');

            // Log model info
            const modelInfo = openaiClient.getModelInfo();
            console.log(`   Model: ${modelInfo.model}`);
            console.log(`   Max tokens: ${modelInfo.maxTokens}`);
        }

        // Start Express server on 0.0.0.0 for Android emulator access
        app.listen(config.port, '0.0.0.0', () => {
            console.log('');
            console.log('🚀 Surge AI Gateway started');
            console.log(`   Environment: ${config.nodeEnv}`);
            console.log(`   Port: ${config.port}`);
            console.log(`   Host: 0.0.0.0 (accessible from emulator)`);
            console.log(`   AI Provider: OpenAI`);
            console.log(`   Model: ${config.openai.model}`);
            console.log('');
            console.log(`   Local: http://localhost:${config.port}/api/v1/surge-ai/chat`);
            console.log(`   Emulator: http://10.0.2.2:${config.port}/api/v1/surge-ai/chat`);
            console.log('');
        });
    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully...');
    process.exit(0);
});

// Start the server
startServer();

export default app;
