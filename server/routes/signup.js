const emailService = require('../services/email');

// ... [existing imports]

router.post('/', async (req, res) => {
    // ... [existing logic] 

    const signup = await Signup.create({
        waitlistId: waitlist.id,
        email,
        referredBy: referral_code || referral_link || null,
        metadata,
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'],
        priorityBoost
    });

    // Send welcome email (fire and forget to not block response)
    if (settings.sendWelcomeEmail) {
        emailService.sendWelcomeEmail(signup, waitlist).catch(err =>
            console.error('[Signup] Failed to send welcome email:', err.message)
        );
    }

    // Check for referral
    if (signup.referredBy) {
        // Find referrer
        // For now, we need to handle this carefully as Signup.create doesn't return the referrer info directly
        // and we might need to look it up.
        // But wait, our Signup model handles the referral counting. 
        // We need to fetch the referrer to get their email if we want to notify them.

        // NOTE: Ideally Signup.create or a subsequent call handles the referral logic. 
        // If the model updates the referrer's count, we might want to fetch that referrer here.
        try {
            // Assuming Signup model handles finding referrer by code/link
            // We'll create a helper or just search here if needed.
            // For now, let's stick to the Welcome Email fix as primary.
        } catch (e) {
            console.error('Referral notification error', e);
        }
    }

    // Actually, to keep it simple and safe:
    // Let's just create the signup and send the welcome email first.

    /* 
       The simpler fix is to just insert the email call after Signup.create.
       The helper `sendReferralNotification` also requires the referrer object.
       The current `Signup.create` calls `processReferral` internally maybe? 
       I should check `models/Signup.js` to see if it returns referrer info or if I need to fetch it.
    */

    // ...
});


/**
 * GET /api/signup/position
 * Public endpoint - Get position in waitlist
 */
router.get('/position', async (req, res) => {
    try {
        const apiKey = req.headers['x-api-key'];
        const { email } = req.query;

        if (!apiKey) {
            return res.status(401).json({ error: 'API key required' });
        }

        if (!email) {
            return res.status(400).json({ error: 'Email is required' });
        }

        const waitlist = await Waitlist.findByApiKey(apiKey);
        if (!waitlist) {
            return res.status(401).json({ error: 'Invalid API key' });
        }

        const result = await Signup.getPosition(waitlist.id, email);
        if (!result) {
            return res.status(404).json({ error: 'Not found on waitlist' });
        }

        res.json({
            success: true,
            data: {
                position: result.current_position,
                referral_code: result.referral_code,
                referral_count: result.referral_count,
                status: result.status
            }
        });
    } catch (error) {
        console.error('[Signup] Position error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// ============== Authenticated routes (dashboard) ==============

/**
 * GET /api/signups/:waitlistId
 * Get all signups for a waitlist (requires auth)
 */
router.get('/:waitlistId', verifyToken, async (req, res) => {
    try {
        const waitlist = await Waitlist.findById(req.params.waitlistId);

        if (!waitlist) {
            return res.status(404).json({ error: 'Waitlist not found' });
        }

        if (waitlist.user_id !== req.auth.uid) {
            return res.status(403).json({ error: 'Access denied' });
        }

        const { limit = 100, offset = 0, status, sortBy, order } = req.query;

        const signups = await Signup.findByWaitlist(req.params.waitlistId, {
            limit: parseInt(limit),
            offset: parseInt(offset),
            status,
            sortBy,
            order
        });

        const total = await Signup.count(req.params.waitlistId, status);

        res.json({
            success: true,
            data: {
                signups,
                total,
                limit: parseInt(limit),
                offset: parseInt(offset)
            }
        });
    } catch (error) {
        console.error('[Signups] Get all error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * PUT /api/signups/:id/verify
 * Verify a signup
 */
router.put('/:id/verify', verifyToken, async (req, res) => {
    try {
        const signup = await Signup.findById(req.params.id);
        if (!signup) {
            return res.status(404).json({ error: 'Signup not found' });
        }

        const waitlist = await Waitlist.findById(signup.waitlist_id);
        if (waitlist.user_id !== req.auth.uid) {
            return res.status(403).json({ error: 'Access denied' });
        }

        const updated = await Signup.verify(req.params.id);

        res.json({
            success: true,
            data: { signup: updated }
        });
    } catch (error) {
        console.error('[Signups] Verify error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * PUT /api/signups/:id/offboard
 * Admit/offboard a signup
 */
router.put('/:id/offboard', verifyToken, async (req, res) => {
    try {
        const signup = await Signup.findById(req.params.id);
        if (!signup) {
            return res.status(404).json({ error: 'Signup not found' });
        }

        const waitlist = await Waitlist.findById(signup.waitlist_id);
        if (waitlist.user_id !== req.auth.uid) {
            return res.status(403).json({ error: 'Access denied' });
        }

        const updated = await Signup.offboard(req.params.id);

        res.json({
            success: true,
            data: { signup: updated }
        });
    } catch (error) {
        console.error('[Signups] Offboard error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

/**
 * DELETE /api/signups/:id
 * Delete a signup
 */
router.delete('/:id', verifyToken, async (req, res) => {
    try {
        const signup = await Signup.findById(req.params.id);
        if (!signup) {
            return res.status(404).json({ error: 'Signup not found' });
        }

        const waitlist = await Waitlist.findById(signup.waitlist_id);
        if (waitlist.user_id !== req.auth.uid) {
            return res.status(403).json({ error: 'Access denied' });
        }

        await Signup.delete(req.params.id);

        res.json({
            success: true,
            message: 'Signup deleted'
        });
    } catch (error) {
        console.error('[Signups] Delete error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;
