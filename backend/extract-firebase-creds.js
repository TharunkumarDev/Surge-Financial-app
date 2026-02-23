// Firebase Credentials Extractor
// Usage: node extract-firebase-creds.js path/to/service-account.json

const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);

if (args.length === 0) {
    console.error('❌ Please provide the path to your Firebase service account JSON file');
    console.error('Usage: node extract-firebase-creds.js path/to/service-account.json');
    process.exit(1);
}

const jsonPath = args[0];

if (!fs.existsSync(jsonPath)) {
    console.error(`❌ File not found: ${jsonPath}`);
    process.exit(1);
}

try {
    const serviceAccount = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

    console.log('\n✅ Firebase credentials extracted successfully!\n');
    console.log('Copy these lines to your backend/.env file:\n');
    console.log('─────────────────────────────────────────────────\n');
    console.log(`FIREBASE_PROJECT_ID=${serviceAccount.project_id}`);
    console.log(`FIREBASE_PRIVATE_KEY="${serviceAccount.private_key}"`);
    console.log(`FIREBASE_CLIENT_EMAIL=${serviceAccount.client_email}`);
    console.log('\n─────────────────────────────────────────────────\n');

} catch (error) {
    console.error('❌ Error reading JSON file:', error.message);
    process.exit(1);
}
