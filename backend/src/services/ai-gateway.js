import { db } from '../config/firebase.js';
import { PrivacyFilter } from './privacy-filter.js';
import { PromptBuilder } from './prompt-builder.js';
import { openaiClient } from './openai-client.js';

/**
 * AI Gateway Service
 * Main orchestration layer for AI chat functionality
 * Coordinates privacy filtering, prompt building, and AI generation
 */

export class AIGatewayService {
    /**
     * Process a chat message and generate AI response
     * @param {string} userId - Firebase user ID
     * @param {string} message - User's message
     * @param {string} sessionId - Chat session ID
     * @returns {Promise<Object>} - AI response with metadata
     */
    async processMessage(userId, message, sessionId) {
        try {
            // Step 1: Fetch user's financial data from Firestore
            const financialData = await this._fetchFinancialData(userId);

            // Step 2: Apply privacy filter
            const safeData = PrivacyFilter.sanitizeForAI(financialData);

            // Step 3: Validate no PII
            PrivacyFilter.validateNoPII(safeData);

            // Step 4: Build AI prompts (system + user)
            const { systemPrompt, userPrompt } = PromptBuilder.buildPrompt(message, safeData);

            // Step 5: Generate AI response using OpenAI
            const aiResponse = await openaiClient.generate(systemPrompt, userPrompt);

            // Step 6: Save chat history
            await this._saveChatMessage(userId, sessionId, message, aiResponse);

            // Step 7: Return clean response
            return {
                reply: aiResponse,
                timestamp: new Date().toISOString(),
                sessionId: sessionId,
            };
        } catch (error) {
            console.error('AI Gateway error:', error.message);

            // Return user-friendly error messages
            return this._handleError(error);
        }
    }

    /**
     * Fetch aggregated financial data for user
     * @param {string} userId - Firebase user ID
     * @returns {Promise<Object>} - Aggregated financial data
     */
    async _fetchFinancialData(userId) {
        try {
            // Fetch user document
            const userDoc = await db.collection('users').doc(userId).get();

            if (!userDoc.exists) {
                return {};
            }

            const userData = userDoc.data();

            // Get current month expenses
            const now = new Date();
            const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

            const expensesSnapshot = await db
                .collection('users')
                .doc(userId)
                .collection('expenses')
                .where('date', '>=', startOfMonth)
                .get();

            const transactions = expensesSnapshot.docs.map(doc => doc.data());

            // Calculate aggregated stats
            const totalSpending = transactions.reduce((sum, tx) => sum + (tx.amount || 0), 0);
            const daysElapsed = now.getDate();
            const daysRemaining = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate() - daysElapsed;

            return {
                currentBalance: userData.currentBalance || 0,
                monthlySpending: totalSpending,
                dailyAverage: daysElapsed > 0 ? totalSpending / daysElapsed : 0,
                daysRemaining: daysRemaining,
                transactions: transactions,  // Will be filtered by PrivacyFilter
            };
        } catch (error) {
            console.error('Error fetching financial data:', error);
            return {};
        }
    }

    /**
     * Save chat message to Firestore
     * @param {string} userId - Firebase user ID
     * @param {string} sessionId - Chat session ID
     * @param {string} userMessage - User's message
     * @param {string} aiResponse - AI's response
     */
    async _saveChatMessage(userId, sessionId, userMessage, aiResponse) {
        try {
            await db
                .collection('users')
                .doc(userId)
                .collection('ai_chats')
                .add({
                    sessionId: sessionId,
                    userMessage: userMessage,
                    aiResponse: aiResponse,
                    timestamp: new Date(),
                    createdAt: new Date(),
                });
        } catch (error) {
            console.error('Error saving chat message:', error);
            // Non-critical error - don't fail the request
        }
    }

    /**
     * Handle errors and return user-friendly messages
     * @param {Error} error - Error object
     * @returns {Object} - Error response
     */
    _handleError(error) {
        const errorMap = {
            'AI_SERVICE_UNAVAILABLE': 'AI service is temporarily unavailable. Please try again in a moment.',
            'AI_SERVICE_TIMEOUT': 'Request timed out. Please try again.',
            'AI_SERVICE_ERROR': 'Something went wrong. Please try again.',
            'AI_SERVICE_QUOTA_EXCEEDED': 'AI service quota exceeded. Please contact support.',
            'AI_SERVICE_RATE_LIMIT': 'Too many AI requests. Please try again in a moment.',
            'AI_SERVICE_AUTH_ERROR': 'AI service authentication error. Please contact support.',
            'PII detected': 'Unable to process request due to privacy constraints.',
        };

        const message = errorMap[error.message] || 'An error occurred. Please try again.';

        return {
            error: message,
            timestamp: new Date().toISOString(),
        };
    }
}

// Singleton instance
export const aiGatewayService = new AIGatewayService();
