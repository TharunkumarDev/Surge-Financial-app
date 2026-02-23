import express from 'express';
import { verifyFirebaseToken } from '../middleware/auth.js';
import { rateLimiter } from '../middleware/rate-limiter.js';
import { aiGatewayService } from '../services/ai-gateway.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

/**
 * POST /api/v1/surge-ai/chat
 * Main AI chat endpoint
 * 
 * Request:
 *   Headers: Authorization: Bearer <firebase-id-token>
 *   Body: { message: string, sessionId?: string }
 * 
 * Response:
 *   { reply: string, timestamp: string, sessionId: string }
 */
router.post('/chat', verifyFirebaseToken, rateLimiter, async (req, res) => {
    try {
        const { message, sessionId } = req.body;

        // Validation
        if (!message || typeof message !== 'string') {
            return res.status(400).json({
                error: 'Message is required and must be a string.',
            });
        }

        if (message.trim().length === 0) {
            return res.status(400).json({
                error: 'Message cannot be empty.',
            });
        }

        if (message.length > 500) {
            return res.status(400).json({
                error: 'Message is too long. Please keep it under 500 characters.',
            });
        }

        // Generate session ID if not provided
        const chatSessionId = sessionId || uuidv4();

        // Process message through AI gateway
        const result = await aiGatewayService.processMessage(
            req.user.uid,
            message.trim(),
            chatSessionId
        );

        // Return response
        res.json(result);
    } catch (error) {
        console.error('Chat endpoint error:', error);

        res.status(500).json({
            error: 'An error occurred processing your request. Please try again.',
            timestamp: new Date().toISOString(),
        });
    }
});

/**
 * GET /api/v1/surge-ai/health
 * Health check endpoint (no auth required)
 */
router.get('/health', async (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        service: 'surge-ai-gateway',
    });
});

/**
 * GET /api/v1/surge-ai/usage
 * Get user's AI usage stats
 */
router.get('/usage', verifyFirebaseToken, async (req, res) => {
    try {
        // Get usage from rate limiter headers
        const dailyLimit = res.getHeader('X-RateLimit-Limit-Daily');
        const dailyRemaining = res.getHeader('X-RateLimit-Remaining-Daily');
        const tier = res.getHeader('X-RateLimit-Tier');

        res.json({
            tier: tier || 'free',
            dailyLimit: dailyLimit || 5,
            dailyRemaining: dailyRemaining || 5,
            dailyUsed: (dailyLimit || 5) - (dailyRemaining || 5),
        });
    } catch (error) {
        console.error('Usage endpoint error:', error);
        res.status(500).json({ error: 'Failed to fetch usage stats.' });
    }
});

export default router;
