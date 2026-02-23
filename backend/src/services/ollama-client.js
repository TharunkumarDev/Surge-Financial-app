import axios from 'axios';
import config from '../config/index.js';

/**
 * Ollama Client Service
 * Handles communication with local Ollama server
 * INTERNAL NETWORK ONLY - never exposed to public internet
 */

export class OllamaClient {
    constructor() {
        this.host = config.ollama.host;
        this.model = config.ollama.model;
        this.timeout = config.ollama.timeout;
        this.maxTokens = config.ollama.maxTokens;
    }

    /**
     * Generate AI response from Ollama
     * @param {string} prompt - Complete prompt with system instructions
     * @returns {Promise<string>} - AI-generated response
     */
    async generate(prompt) {
        try {
            const response = await axios.post(
                `${this.host}/api/generate`,
                {
                    model: this.model,
                    prompt: prompt,
                    stream: false,
                    options: {
                        temperature: 0.7,
                        num_predict: this.maxTokens,
                        top_p: 0.9,
                        top_k: 40,
                    },
                },
                {
                    timeout: this.timeout,
                    headers: {
                        'Content-Type': 'application/json',
                    },
                }
            );

            if (response.data && response.data.response) {
                return this._sanitizeResponse(response.data.response);
            }

            throw new Error('Invalid response from Ollama');
        } catch (error) {
            console.error('Ollama generation error:', error.message);

            // Never expose internal errors to client
            if (error.code === 'ECONNREFUSED') {
                throw new Error('AI_SERVICE_UNAVAILABLE');
            }

            if (error.code === 'ETIMEDOUT') {
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
        // Remove any potential model artifacts
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
     * Check if Ollama server is available
     * @returns {Promise<boolean>} - True if server is up
     */
    async healthCheck() {
        try {
            const response = await axios.get(`${this.host}/api/tags`, {
                timeout: 5000,
            });

            return response.status === 200;
        } catch (error) {
            console.error('Ollama health check failed:', error.message);
            return false;
        }
    }

    /**
     * Get available models from Ollama
     * @returns {Promise<Array>} - List of available models
     */
    async getModels() {
        try {
            const response = await axios.get(`${this.host}/api/tags`);
            return response.data.models || [];
        } catch (error) {
            console.error('Failed to get models:', error.message);
            return [];
        }
    }
}

// Singleton instance
export const ollamaClient = new OllamaClient();
