const { db } = require('./config/database');
const Subscription = require('./models/Subscription');

async function seedPlans() {
    console.log('Seeding pricing plans...');

    const plans = [
        {
            name: 'Basic',
            description: 'For individuals and small projects',
            monthlyPrice: 15,
            annualPrice: 120, // $10/mo
            maxWaitlists: null, // Unlimited
            maxSignupsPerMonth: null, // Unlimited
            maxTeamMembers: 1,
            features: [
                'custom_branding',
                'api_access',
                'webhooks',
                'analytics_basic'
            ],
            sortOrder: 1
        },
        {
            name: 'Advanced',
            description: 'For growing businesses',
            monthlyPrice: 50,
            annualPrice: 396, // $33/mo
            maxWaitlists: null,
            maxSignupsPerMonth: null,
            maxTeamMembers: 5,
            features: [
                'custom_branding',
                'api_access',
                'webhooks',
                'analytics_basic',
                'remove_branding',
                'zapier_integration',
                'hide_position_count',
                'block_personal_emails',
                'allowed_domains'
            ],
            sortOrder: 2
        },
        {
            name: 'Pro',
            description: 'For power users and teams',
            monthlyPrice: 250,
            annualPrice: 2004, // $167/mo
            maxWaitlists: null,
            maxSignupsPerMonth: null,
            maxTeamMembers: null, // Unlimited
            features: [
                'custom_branding',
                // Basic features
                'api_access',
                'webhooks',
                'analytics_deep',

                // Advanced features
                'remove_branding',
                'zapier_integration',
                'hide_position_count',
                'block_personal_emails',
                'allowed_domains',

                // Pro features
                'custom_email_templates',
                'custom_offboarding_email',
                'custom_domain_emails',
                'email_blasts',
                'multi_user_team'
            ],
            sortOrder: 3
        }
    ];

    for (const plan of plans) {
        // Check if plan exists by name
        const existingPlans = await db.collection('subscription_plans')
            .where('name', '==', plan.name)
            .get();

        if (!existingPlans.empty) {
            console.log(`Plan ${plan.name} already exists. Updating...`);
            const doc = existingPlans.docs[0];
            await db.collection('subscription_plans').doc(doc.id).update({
                description: plan.description,
                monthly_price: plan.monthlyPrice,
                annual_price: plan.annualPrice,
                max_waitlists: plan.maxWaitlists,
                max_signups_per_month: plan.maxSignupsPerMonth,
                max_team_members: plan.maxTeamMembers,
                features: plan.features,
                sort_order: plan.sortOrder
            });
        } else {
            console.log(`Creating plan ${plan.name}...`);
            await Subscription.createPlan(plan);
        }
    }

    console.log('Plans seeded successfully.');
    process.exit(0);
}

seedPlans().catch(console.error);
