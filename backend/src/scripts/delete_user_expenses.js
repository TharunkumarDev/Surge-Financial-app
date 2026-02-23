#!/usr/bin/env node

/**
 * Delete All Expense Data for a User
 * 
 * Usage: node src/scripts/delete_user_expenses.js <email>
 * Example: node src/scripts/delete_user_expenses.js tharun98414@gmail.com
 * 
 * This script will:
 * 1. Find the user by email
 * 2. Delete all expense documents from Firestore
 * 3. Optionally delete bill images from Firebase Storage
 */

import admin from 'firebase-admin';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

// Load environment variables
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: join(__dirname, '../../.env') });

// Initialize Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    }),
});

const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();

/**
 * Delete all expenses for a user
 */
async function deleteUserExpenses(email) {
    console.log(`\n🔍 Looking up user with email: ${email}`);

    try {
        // Step 1: Get user by email
        const userRecord = await auth.getUserByEmail(email);
        const userId = userRecord.uid;

        console.log(`✅ Found user: ${userRecord.displayName || 'N/A'} (UID: ${userId})`);

        // Step 2: Count expenses before deletion
        const expensesRef = db.collection('users').doc(userId).collection('expenses');
        const snapshot = await expensesRef.get();
        const expenseCount = snapshot.size;

        console.log(`📊 Found ${expenseCount} expense(s) to delete`);

        if (expenseCount === 0) {
            console.log('✅ No expenses to delete. Exiting.');
            return;
        }

        // Step 3: Confirm deletion
        console.log('\n⚠️  WARNING: This will permanently delete all expense data!');
        console.log('Press Ctrl+C to cancel, or wait 5 seconds to proceed...\n');

        await new Promise(resolve => setTimeout(resolve, 5000));

        // Step 4: Delete expenses in batches (Firestore batch limit is 500)
        console.log('🗑️  Deleting expenses...');

        const batchSize = 500;
        let deletedCount = 0;

        while (true) {
            const batch = db.batch();
            const docs = await expensesRef.limit(batchSize).get();

            if (docs.empty) break;

            docs.forEach(doc => {
                batch.delete(doc.ref);
            });

            await batch.commit();
            deletedCount += docs.size;

            console.log(`   Deleted ${deletedCount}/${expenseCount} expenses...`);
        }

        console.log(`✅ Successfully deleted ${deletedCount} expense(s)`);

        // Step 5: Delete bill images from Storage (optional)
        console.log('\n🖼️  Checking for bill images in Storage...');

        try {
            const bucket = storage.bucket();
            const [files] = await bucket.getFiles({
                prefix: `users/${userId}/bill_images/`
            });

            if (files.length > 0) {
                console.log(`📊 Found ${files.length} bill image(s) to delete`);

                for (const file of files) {
                    await file.delete();
                }

                console.log(`✅ Successfully deleted ${files.length} bill image(s)`);
            } else {
                console.log('✅ No bill images found');
            }
        } catch (storageError) {
            console.warn('⚠️  Could not delete bill images (Storage bucket may not be configured):', storageError.message);
        }

        // Step 6: Summary
        console.log('\n' + '='.repeat(60));
        console.log('✅ DELETION COMPLETE');
        console.log('='.repeat(60));
        console.log(`User Email: ${email}`);
        console.log(`User ID: ${userId}`);
        console.log(`Expenses Deleted: ${deletedCount}`);
        console.log('='.repeat(60));
        console.log('\n⚠️  Note: Local app data (Isar) will remain until the user clears app data manually.\n');

    } catch (error) {
        if (error.code === 'auth/user-not-found') {
            console.error(`❌ Error: No user found with email: ${email}`);
        } else {
            console.error('❌ Error during deletion:', error);
        }
        process.exit(1);
    }
}

// Main execution
const email = process.argv[2];

if (!email) {
    console.error('❌ Error: Email address is required');
    console.log('\nUsage: node src/scripts/delete_user_expenses.js <email>');
    console.log('Example: node src/scripts/delete_user_expenses.js tharun98414@gmail.com\n');
    process.exit(1);
}

deleteUserExpenses(email)
    .then(() => {
        console.log('✅ Script completed successfully');
        process.exit(0);
    })
    .catch((error) => {
        console.error('❌ Script failed:', error);
        process.exit(1);
    });
