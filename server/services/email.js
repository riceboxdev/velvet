const sgMail = require('@sendgrid/mail');

class EmailService {
  constructor() {
    if (process.env.SENDGRID_API_KEY) {
      sgMail.setApiKey(process.env.SENDGRID_API_KEY);
      this.enabled = true;
    } else {
      console.warn('[Email] SENDGRID_API_KEY not found. Email sending disabled.');
      this.enabled = false;
    }
    this.from = process.env.EMAIL_FROM || 'noreply@waitlist.local';
  }

  async sendWelcomeEmail(signup, waitlist) {
    if (!this.enabled) return null;

    const settings = waitlist.settings || {};
    const subject = settings.welcomeEmailSubject || `Welcome to the ${waitlist.name} waitlist!`;

    const referralLink = `${process.env.BASE_URL || 'http://localhost:3000'}/join/${waitlist.id}?ref=${signup.referral_code}`;

    const html = settings.welcomeEmailTemplate || `
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #333;">You're on the list! 🎉</h1>
        <p>Thanks for joining the <strong>${waitlist.name}</strong> waitlist.</p>
        <p>Your current position: <strong>#${signup.position}</strong></p>
        
        <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">
          <h3 style="margin-top: 0;">Want to move up?</h3>
          <p>Share your unique referral link with friends:</p>
          <a href="${referralLink}" style="display: inline-block; background: #3b82f6; color: white; padding: 12px 24px; border-radius: 6px; text-decoration: none;">
            ${referralLink}
          </a>
          <p style="font-size: 14px; color: #666; margin-bottom: 0;">
            Each friend who joins will move you up the list!
          </p>
        </div>
        
        <p style="color: #666; font-size: 14px;">
          Your referral code: <code style="background: #eee; padding: 2px 6px; border-radius: 4px;">${signup.referral_code}</code>
        </p>
      </div>
    `;

    try {
      const msg = {
        to: signup.email,
        from: this.from,
        subject,
        html
      };
      const result = await sgMail.send(msg);
      console.log(`[Email] Sent welcome email to ${signup.email}`);
      return result;
    } catch (error) {
      console.error(`[Email] Failed to send welcome email: ${error.message}`);
      if (error.response) {
        console.error(error.response.body);
      }
      throw error; // Re-throw or handle as needed
    }
  }

  async sendReferralNotification(referrer, newReferralCount, waitlist) {
    if (!this.enabled) return null;

    const html = `
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #333;">Someone used your referral! 🎊</h1>
        <p>Great news! Someone just joined <strong>${waitlist.name}</strong> using your referral link.</p>
        <p>You now have <strong>${newReferralCount} referrals</strong>!</p>
        <p style="color: #666;">Keep sharing to move up the list even faster.</p>
      </div>
    `;

    try {
      const msg = {
        to: referrer.email,
        from: this.from,
        subject: `You got a new referral on ${waitlist.name}!`,
        html
      };
      return await sgMail.send(msg);
    } catch (error) {
      console.error(`[Email] Failed to send referral notification: ${error.message}`);
      if (error.response) {
        console.error(error.response.body);
      }
      // Don't throw for notifications to avoid breaking the signup flow of the referred user
      return null;
    }
  }

  async sendOffboardingEmail(signup, waitlist) {
    if (!this.enabled) return null;

    const settings = waitlist.settings || {};
    const subject = settings.offboardEmailSubject || `You're in! Welcome to ${waitlist.name}`;

    const html = settings.offboardEmailTemplate || `
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #333;">🎉 You've been granted access!</h1>
        <p>Congratulations! You've been selected from the <strong>${waitlist.name}</strong> waitlist.</p>
        <p>We're excited to have you join us!</p>
        <p style="color: #666;">Check your inbox for further instructions.</p>
      </div>
    `;

    try {
      const msg = {
        to: signup.email,
        from: this.from,
        subject,
        html
      };
      return await sgMail.send(msg);
    } catch (error) {
      console.error(`[Email] Failed to send offboarding email: ${error.message}`);
      if (error.response) {
        console.error(error.response.body);
      }
      throw error;
    }
  }
}

module.exports = new EmailService();
