import OpenAI from 'openai';
import config from '../config/index.js';

/**
 * OpenAI Client Service
 * Handles communication with OpenAI API
 * API key is server-side only - NEVER exposed to client
 */

export class OpenAIClient {
    constructor() {
        this.client = new OpenAI({
            apiKey: config.openai.apiKey,
        });
        this.model = config.openai.model;
        this.maxTokens = config.openai.maxTokens;
        this.temperature = config.openai.temperature;
    }

    /**
     * Generate AI response from OpenAI
     * @param {string} systemPrompt - System instructions
     * @param {string} userPrompt - User message with context
     * @returns {Promise<string>} - AI-generated response
     */
    async generate(systemPrompt, userPrompt) {
        try {
            const completion = await this.client.chat.completions.create({
                model: this.model,
                messages: [
                    {
                        role: 'system',
                        content: systemPrompt,
                    },
                    {
                        role: 'user',
                        content: userPrompt,
                    },
                ],
                max_tokens: this.maxTokens,
                temperature: this.temperature,
                top_p: 0.9,
            });

            if (completion.choices && completion.choices.length > 0) {
                const response = completion.choices[0].message.content;
                return this._sanitizeResponse(response);
            }

            throw new Error('No response from OpenAI');
        } catch (error) {
            console.error('OpenAI generation error:', error.message);

            // Never expose internal errors to client
            if (error.code === 'insufficient_quota') {
                throw new Error('AI_SERVICE_QUOTA_EXCEEDED');
            }

            if (error.code === 'rate_limit_exceeded') {
                throw new Error('AI_SERVICE_RATE_LIMIT');
            }

            if (error.status === 401) {
                throw new Error('AI_SERVICE_AUTH_ERROR');
            }

            if (error.code === 'ETIMEDOUT' || error.code === 'ECONNABORTED') {
                throw new Error('AI_SERVICE_TIMEOUT');
            }

            throw new Error('AI_SERVICE_ERROR');
        }
    }

    /**
     * Sanitize AI response before sending to client
     * @param {string} response - Raw AI response
     * @returns {string} - Sanitized response
     */
    _sanitizeResponse(response) {
        if (!response) return '';

        // Remove any potential system prompt leakage
        let sanitized = response.trim();

        // Remove common AI artifacts
        sanitized = sanitized.replace(/^(Assistant:|AI:|Surge:)\s*/i, '');

        // Limit length (safety check)
        if (sanitized.length > 500) {
            sanitized = sanitized.substring(0, 500) + '...';
        }

        return sanitized;
    }

    /**
     * Check if OpenAI API is accessible
     * @returns {Promise<boolean>} - True if API is accessible
     */
    async healthCheck() {
        try {
            await this.client.models.list();
            return true;
        } catch (error) {
            console.error('OpenAI health check failed:', error.message);
            return false;
        }
    }

    /**
     * Get current model info
     * @returns {Object} - Model configuration
     */
    getModelInfo() {
        return {
            model: this.model,
            maxTokens: this.maxTokens,
            temperature: this.temperature,
        };
    }
}

// Singleton instance
export const openaiClient = new OpenAIClient();
