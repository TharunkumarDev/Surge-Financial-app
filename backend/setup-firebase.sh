#!/bin/bash

# Firebase Service Account Setup Script
# This script helps you get the Firebase Admin SDK credentials

echo "🔥 Firebase Service Account Setup"
echo "=================================="
echo ""
echo "To get your Firebase Admin SDK credentials:"
echo ""
echo "1. Go to: https://console.firebase.google.com/project/surge-financial-tracking-app/settings/serviceaccounts/adminsdk"
echo ""
echo "2. Click 'Generate New Private Key'"
echo ""
echo "3. Download the JSON file"
echo ""
echo "4. Run this command to extract the credentials:"
echo ""
echo "   node extract-firebase-creds.js path/to/your-service-account.json"
echo ""
echo "5. Copy the output and paste it into backend/.env"
echo ""
