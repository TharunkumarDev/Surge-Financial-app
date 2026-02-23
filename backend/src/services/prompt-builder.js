/**
 * Prompt Builder Service
 * Constructs AI prompts with privacy-safe financial context
 * Templates are server-side only - never exposed to Flutter app
 */

export class PromptBuilder {
    static SYSTEM_PROMPT = `You are Surge, a helpful financial assistant for an expense tracking app.

Your role:
- Provide concise, actionable financial advice
- Be conversational and friendly
- Keep responses under 100 words
- Never ask for personal information
- Focus on spending patterns and budgeting tips

Guidelines:
- Use Indian Rupee (₹) for all amounts
- Provide specific, actionable recommendations
- Be encouraging and supportive
- Avoid technical jargon`;

    /**
   * Build prompts for OpenAI (separate system and user messages)
   * @param {string} userMessage - User's question
   * @param {Object} financialContext - Aggregated financial data
   * @returns {Object} - {systemPrompt, userPrompt}
   */
    static buildPrompt(userMessage, financialContext) {
        const context = this._formatFinancialContext(financialContext);

        const userPrompt = `User question: "${userMessage}"

Financial context:
${context}

Provide a helpful, conversational response in under 100 words.`;

        return {
            systemPrompt: this.SYSTEM_PROMPT,
            userPrompt: userPrompt,
        };
    }

    /**
     * Format financial context into readable text
     * @param {Object} data - Aggregated financial data
     * @returns {string} - Formatted context
     */
    static _formatFinancialContext(data) {
        const parts = [];

        if (data.currentBalance !== undefined) {
            parts.push(`- Current balance: ₹${data.currentBalance.toLocaleString('en-IN')}`);
        }

        if (data.monthlySpending !== undefined) {
            parts.push(`- Monthly spending: ₹${data.monthlySpending.toLocaleString('en-IN')}`);
        }

        if (data.categoryBreakdown) {
            const topCategories = Object.entries(data.categoryBreakdown)
                .sort((a, b) => b[1].percentage - a[1].percentage)
                .slice(0, 3)
                .map(([cat, data]) => `${cat} (${data.percentage}%)`)
                .join(', ');

            if (topCategories) {
                parts.push(`- Top spending categories: ${topCategories}`);
            }
        }

        if (data.dailyAverage !== undefined) {
            parts.push(`- Daily average spend: ₹${Math.round(data.dailyAverage).toLocaleString('en-IN')}`);
        }

        if (data.daysRemaining !== undefined) {
            parts.push(`- Days remaining in month: ${data.daysRemaining}`);
        }

        if (data.weekendRatio !== undefined && data.weekendRatio > 1.5) {
            parts.push(`- Note: Weekend spending is ${data.weekendRatio.toFixed(1)}x higher than weekdays`);
        }

        return parts.length > 0 ? parts.join('\n') : '- No financial data available yet';
    }

    /**
   * Build a simple greeting prompt (no financial context needed)
   * @returns {Object} - {systemPrompt, userPrompt}
   */
    static buildGreetingPrompt() {
        return {
            systemPrompt: this.SYSTEM_PROMPT,
            userPrompt: 'Hi! I need help with my finances.',
        };
    }
}
