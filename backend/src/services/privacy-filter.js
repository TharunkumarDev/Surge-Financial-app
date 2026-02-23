/**
 * Privacy Filter Service
 * Converts raw financial data into aggregated, privacy-safe summaries
 * NEVER sends PII or raw transaction lists to AI
 */

export class PrivacyFilter {
    /**
     * Sanitize financial data for AI consumption
     * @param {Object} rawData - Raw financial data from Firestore
     * @returns {Object} - Privacy-safe aggregated data
     */
    static sanitizeForAI(rawData) {
        const sanitized = {};

        // Remove all PII fields
        const piiFields = ['userId', 'deviceId', 'email', 'phone', 'address', 'name'];
        piiFields.forEach(field => delete rawData[field]);

        // Convert raw transactions to aggregated stats
        if (rawData.transactions && Array.isArray(rawData.transactions)) {
            const transactions = rawData.transactions;

            // Aggregate by category
            const categoryTotals = {};
            let totalSpending = 0;

            transactions.forEach(tx => {
                const category = tx.category || 'other';
                categoryTotals[category] = (categoryTotals[category] || 0) + tx.amount;
                totalSpending += tx.amount;
            });

            // Convert to percentages
            const categoryBreakdown = {};
            Object.entries(categoryTotals).forEach(([category, amount]) => {
                categoryBreakdown[category] = {
                    percentage: totalSpending > 0 ? Math.round((amount / totalSpending) * 100) : 0,
                    amount: Math.round(amount),
                };
            });

            sanitized.monthlySpending = Math.round(totalSpending);
            sanitized.categoryBreakdown = categoryBreakdown;
            sanitized.transactionCount = transactions.length;

            // Remove raw transaction list
            delete rawData.transactions;
        }

        // Keep only safe aggregated fields
        const safeFields = [
            'currentBalance',
            'monthlySpending',
            'categoryBreakdown',
            'weekendRatio',
            'daysRemaining',
            'dailyAverage',
            'topCategory',
            'transactionCount',
        ];

        safeFields.forEach(field => {
            if (rawData[field] !== undefined) {
                sanitized[field] = rawData[field];
            }
        });

        return sanitized;
    }

    /**
     * Validate that data contains no PII before sending to AI
     * @param {Object} data - Data to validate
     * @returns {boolean} - True if safe, throws error if PII detected
     */
    static validateNoPII(data) {
        const dataStr = JSON.stringify(data).toLowerCase();

        // Check for common PII patterns
        const piiPatterns = [
            /@/,  // Email addresses
            /\d{10,}/,  // Phone numbers (10+ digits)
            /\d{4}-\d{4}-\d{4}-\d{4}/,  // Credit card patterns
        ];

        for (const pattern of piiPatterns) {
            if (pattern.test(dataStr)) {
                throw new Error('PII detected in AI payload - request blocked');
            }
        }

        return true;
    }
}
