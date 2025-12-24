require('dotenv').config();
const emailService = require('./services/email');

async function testEmail() {
    console.log('Testing Email Service...');
    console.log('SENDGRID_API_KEY present:', !!process.env.SENDGRID_API_KEY);
    console.log('Email Service enabled:', emailService.enabled);

    if (!process.env.SENDGRID_API_KEY) {
        console.error('ERROR: SENDGRID_API_KEY is missing from environment variables.');
        return;
    }

    const mockSignup = {
        email: 'your_verification_email@example.com', // User should replace this or I'll just use a fake one and look for the error
        position: 42,
        referral_code: 'TEST1234'
    };

    const mockWaitlist = {
        id: 'test-waitlist',
        name: 'Test Waitlist',
        settings: {}
    };

    try {
        console.log('Attempting to send welcome email...');
        // We accept the error if the email is fake, but we want to see the SendGrid response
        const result = await emailService.sendWelcomeEmail(mockSignup, mockWaitlist);
        console.log('Result:', result);
    } catch (error) {
        console.error('Test Failed:', error.message);
        if (error.response) {
            console.error('SendGrid Error Body:', JSON.stringify(error.response.body, null, 2));
        }
    }
}

testEmail();
