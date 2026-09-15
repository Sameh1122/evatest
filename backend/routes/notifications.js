const express = require('express');
const { dbData, saveDb, getNextId } = require('../database');
const { verifyToken, requireRoles } = require('../middleware/auth');

const router = express.Router();

// Ensure notification collections exist in dbData
if (!dbData.notifications) dbData.notifications = [];
if (!dbData.notification_automation) {
  dbData.notification_automation = {
    ai_recommendation_trigger: true,
    discount_broadcast_auto: true,
    abandoned_cart_sms: true,
    low_stock_admin_alert: true,
  };
}

// 1. Get Notification Campaigns & History (Admin only)
router.get('/campaigns', verifyToken, requireRoles(['admin']), (req, res) => {
  res.json({
    campaigns: dbData.notifications || [],
    automation_settings: dbData.notification_automation,
    total_campaigns: (dbData.notifications || []).length,
  });
});

// 2. Dispatch / Schedule Multi-Channel Notification Campaign (Admin only)
router.post('/send', verifyToken, requireRoles(['admin']), (req, res) => {
  const {
    title,
    message,
    channels, // e.g. ['android_push', 'ios_push', 'email', 'sms']
    target_segment, // e.g. 'all', 'ai_health_matched', 'chronic_patients', 'inactive'
    campaign_type, // e.g. 'ai_recommendation', 'discount_promo', 'custom'
    attached_discount_code,
    schedule_time,
  } = req.body;

  if (!title || !message) {
    return res.status(400).json({ error: 'Title and message body are required.' });
  }

  const selectedChannels = channels || ['android_push', 'ios_push', 'email'];
  
  // Calculate target audience size
  let recipientCount = dbData.users.filter((u) => u.role === 'client').length;
  if (target_segment === 'chronic_patients') {
    recipientCount = dbData.client_profiles.filter((p) => p.chronic_diseases && p.chronic_diseases.trim().length > 0).length || 1;
  } else if (target_segment === 'ai_health_matched') {
    recipientCount = Math.max(1, Math.round(recipientCount * 0.75));
  }

  const newCampaign = {
    id: getNextId('notifications'),
    title,
    message,
    channels: selectedChannels,
    target_segment: target_segment || 'all',
    campaign_type: campaign_type || 'custom',
    attached_discount_code: attached_discount_code || null,
    recipient_count: recipientCount,
    status: schedule_time ? 'Scheduled' : 'Sent',
    sent_at: new Date().toISOString(),
    open_rate_pct: Math.floor(Math.random() * 25) + 65, // 65-90% simulated open rate
    click_rate_pct: Math.floor(Math.random() * 20) + 30, // 30-50% click rate
    created_by: req.user.email,
  };

  dbData.notifications.unshift(newCampaign);
  saveDb();

  res.status(201).json({
    message: `Notification campaign broadcasted successfully to ${recipientCount} recipients across ${selectedChannels.length} channels.`,
    campaign: newCampaign,
  });
});

// 3. Get Automation Triggers (Admin only)
router.get('/automation', verifyToken, requireRoles(['admin']), (req, res) => {
  res.json({ automation: dbData.notification_automation });
});

// 4. Update Automation Rules (Admin only)
router.patch('/automation', verifyToken, requireRoles(['admin']), (req, res) => {
  const { ai_recommendation_trigger, discount_broadcast_auto, abandoned_cart_sms, low_stock_admin_alert } = req.body;

  if (ai_recommendation_trigger !== undefined) dbData.notification_automation.ai_recommendation_trigger = !!ai_recommendation_trigger;
  if (discount_broadcast_auto !== undefined) dbData.notification_automation.discount_broadcast_auto = !!discount_broadcast_auto;
  if (abandoned_cart_sms !== undefined) dbData.notification_automation.abandoned_cart_sms = !!abandoned_cart_sms;
  if (low_stock_admin_alert !== undefined) dbData.notification_automation.low_stock_admin_alert = !!low_stock_admin_alert;

  saveDb();

  res.json({
    message: 'Notification automation settings updated successfully',
    automation: dbData.notification_automation,
  });
});

// 5. Delete / Cancel Campaign (Admin only)
router.delete('/campaigns/:id', verifyToken, requireRoles(['admin']), (req, res) => {
  const campaignId = parseInt(req.params.id, 10);
  const index = dbData.notifications.findIndex((n) => n.id === campaignId);

  if (index === -1) {
    return res.status(404).json({ error: 'Campaign not found.' });
  }

  dbData.notifications.splice(index, 1);
  saveDb();

  res.json({ message: 'Campaign deleted successfully.' });
});

module.exports = router;
