import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class NotificationCenterPage extends StatefulWidget {
  final AppState state;

  const NotificationCenterPage({Key? key, required this.state}) : super(key: key);

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _targetSegment = 'all';
  String _campaignType = 'ai_recommendation';
  String _attachedDiscount = 'LIMITLESS10';

  bool _channelAndroid = true;
  bool _channelIOS = true;
  bool _channelEmail = true;
  bool _channelSMS = true;

  bool _aiTriggerAuto = true;
  bool _discountBroadcastAuto = true;
  bool _abandonedCartSMS = true;
  bool _lowStockAlert = true;

  bool _isLoading = false;
  List<dynamic> _campaigns = [];

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.fetchNotificationCampaigns();
      setState(() {
        _campaigns = data['campaigns'] ?? [];
        if (data['automation_settings'] != null) {
          final auto = data['automation_settings'];
          _aiTriggerAuto = auto['ai_recommendation_trigger'] ?? true;
          _discountBroadcastAuto = auto['discount_broadcast_auto'] ?? true;
          _abandonedCartSMS = auto['abandoned_cart_sms'] ?? true;
          _lowStockAlert = auto['low_stock_admin_alert'] ?? true;
        }
      });
    } catch (e) {
      print('Error fetching campaigns: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendCampaign() async {
    if (_titleController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter campaign title and message body.')),
      );
      return;
    }

    final selectedChannels = <String>[];
    if (_channelAndroid) selectedChannels.add('android_push');
    if (_channelIOS) selectedChannels.add('ios_push');
    if (_channelEmail) selectedChannels.add('email');
    if (_channelSMS) selectedChannels.add('sms');

    if (selectedChannels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one notification channel.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.sendNotificationCampaign({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'channels': selectedChannels,
        'target_segment': _targetSegment,
        'campaign_type': _campaignType,
        'attached_discount_code': _attachedDiscount != 'none' ? _attachedDiscount : null,
      });

      _titleController.clear();
      _messageController.clear();
      await _fetchCampaigns();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.emeraldDark,
          content: Text(result['message'] ?? 'Campaign broadcasted successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.roseAccent, content: Text('Error sending campaign: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAutomation(String key, bool val) async {
    try {
      await ApiService.updateNotificationAutomation({key: val});
      await _fetchCampaigns();
    } catch (e) {
      print('Error toggling automation: $e');
    }
  }

  Future<void> _deleteCampaign(int id) async {
    try {
      await ApiService.deleteNotificationCampaign(id);
      await _fetchCampaigns();
    } catch (e) {
      print('Error deleting campaign: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600 || widget.state.viewportMode == DeviceViewport.mobileAndroid;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.limitlessGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.limitlessGold.withOpacity(0.4)),
                        ),
                        child: Text('ADMIN MODULE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.limitlessGold)),
                      ),
                      const SizedBox(width: 8),
                      Text('Strictly Restricted', style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Notification & Campaign Center',
                    style: GoogleFonts.outfit(fontSize: isMobile ? 20 : 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Multi-Channel Dispatch (Android, iOS, Email, SMS) linked to AI Health Engine & Promo Discounts.',
                    style: GoogleFonts.inter(fontSize: isMobile ? 11 : 13, color: AppColors.slate400),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.limitlessGold),
                onPressed: _fetchCampaigns,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Top Stats Grid
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 1.6 : 2.0,
            children: [
              _statCard('Total Broadcasts', '${_campaigns.length}', Icons.send_rounded, AppColors.cyanAccent),
              _statCard('Multi-Channels', '4 Active', Icons.cell_tower, AppColors.limitlessGold),
              _statCard('Avg Open Rate', '84.2%', Icons.mark_email_read_outlined, AppColors.emeraldAccent),
              _statCard('AI Triggers', 'Automated', Icons.auto_awesome, AppColors.roseAccent),
            ],
          ),

          const SizedBox(height: 24),

          // Main Section: Composer Form & Automation Rules
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900 && !isMobile) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildComposerCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _buildAutomationCard()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildComposerCard(),
                  const SizedBox(height: 20),
                  _buildAutomationCard(),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Section: Campaign History Table / Cards
          _buildCampaignHistorySection(isMobile),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 11)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildComposerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.limitlessGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, color: AppColors.limitlessGold, size: 22),
              const SizedBox(width: 8),
              Text('Create New Notification Campaign', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),

          // Multi-Channel Checkboxes
          Text('Select Dispatch Channels:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate300)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              _channelChip('📱 Android Push', _channelAndroid, (v) => setState(() => _channelAndroid = v!)),
              _channelChip('🍏 iOS Push', _channelIOS, (v) => setState(() => _channelIOS = v!)),
              _channelChip('📧 Email (SMTP)', _channelEmail, (v) => setState(() => _channelEmail = v!)),
              _channelChip('💬 Mobile SMS', _channelSMS, (v) => setState(() => _channelSMS = v!)),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Campaign Title / Subject',
              labelStyle: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12),
              hintText: 'e.g. 🧬 AI Match: Bio-active Lactoferrin for Immune Health',
              hintStyle: GoogleFonts.inter(color: AppColors.slate500, fontSize: 12),
              filled: true,
              fillColor: AppColors.slate900,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 12),

          // Message Body
          TextField(
            controller: _messageController,
            maxLines: 3,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Message Content',
              labelStyle: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12),
              hintText: 'Enter personalized broadcast message content...',
              hintStyle: GoogleFonts.inter(color: AppColors.slate500, fontSize: 12),
              filled: true,
              fillColor: AppColors.slate900,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 14),

          // Dropdowns Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _dropdownField('Target Audience', _targetSegment, {
                'all': 'All Registered Clients',
                'chronic_patients': 'Chronic Disease Patients',
                'ai_health_matched': 'AI Recommender Matched',
                'inactive': 'Inactive Clients (>30 Days)',
              }, (val) => setState(() => _targetSegment = val!)),

              _dropdownField('Campaign Category', _campaignType, {
                'ai_recommendation': '🧬 AI Health Recommendation',
                'discount_promo': '⚡ Discount Promo Campaign',
                'order_update': '📦 Order Status Alert',
                'custom': '📢 General Announcement',
              }, (val) => setState(() => _campaignType = val!)),

              _dropdownField('Attach Promo Code', _attachedDiscount, {
                'LIMITLESS10': 'LIMITLESS10 (10% Off)',
                'HYDRATE20': 'HYDRATE20 (20% Off)',
                'none': 'None',
              }, (val) => setState(() => _attachedDiscount = val!)),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendCampaign,
              icon: const Icon(Icons.rocket_launch, color: Colors.black),
              label: Text(
                _isLoading ? 'Broadcasting...' : 'Broadcast Multi-Channel Campaign Now',
                style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limitlessGold,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelChip(String label, bool value, ValueChanged<bool?> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: (v) => onChanged(v),
      selectedColor: AppColors.limitlessGold,
      backgroundColor: AppColors.slate900,
      labelStyle: GoogleFonts.inter(fontSize: 11, color: value ? Colors.black : AppColors.slate300, fontWeight: value ? FontWeight.bold : FontWeight.normal),
      checkmarkColor: Colors.black,
    );
  }

  Widget _dropdownField(String label, String value, Map<String, String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 10)),
          DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.slate800,
            underline: const SizedBox(),
            isExpanded: false,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyanAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.cyanAccent, size: 22),
              const SizedBox(width: 8),
              Text('AI & Smart Trigger Automations', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Configure automatic notification rules triggered by the AI Health Engine, discount module, and inventory alerts.',
            style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 11),
          ),
          const SizedBox(height: 16),

          _autoSwitch(
            '🧬 AI Recommendation Auto-Notify',
            'Automatically alert clients via Push/Email when AI finds a safe supplement match for their chronic conditions.',
            _aiTriggerAuto,
            (val) {
              setState(() => _aiTriggerAuto = val);
              _toggleAutomation('ai_recommendation_trigger', val);
            },
          ),
          const Divider(color: AppColors.slate700, height: 20),

          _autoSwitch(
            '⚡ Auto Promo Discount Broadcast',
            'Automatically broadcast new promotional discount codes to active client mobile devices.',
            _discountBroadcastAuto,
            (val) {
              setState(() => _discountBroadcastAuto = val);
              _toggleAutomation('discount_broadcast_auto', val);
            },
          ),
          const Divider(color: AppColors.slate700, height: 20),

          _autoSwitch(
            '💬 Abandoned Cart SMS Reminder',
            'Send an SMS reminder with attached discount after 24h of item inactivity in cart.',
            _abandonedCartSMS,
            (val) {
              setState(() => _abandonedCartSMS = val);
              _toggleAutomation('abandoned_cart_sms', val);
            },
          ),
          const Divider(color: AppColors.slate700, height: 20),

          _autoSwitch(
            '📦 Low Stock Admin Alert',
            'Push high-priority SMS/Email alerts to admins when product inventory drops below 15 units.',
            _lowStockAlert,
            (val) {
              setState(() => _lowStockAlert = val);
              _toggleAutomation('low_stock_admin_alert', val);
            },
          ),
        ],
      ),
    );
  }

  Widget _autoSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 10)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.limitlessGold,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCampaignHistorySection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Broadcast History & Performance', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${_campaigns.length} Campaigns Recorded', style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),

          if (_campaigns.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.center,
              child: Text('No campaigns broadcasted yet.', style: GoogleFonts.inter(color: AppColors.slate400)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _campaigns.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.slate700, height: 20),
              itemBuilder: (context, index) {
                final c = _campaigns[index];
                final channels = List<String>.from(c['channels'] ?? []);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            c['title'] ?? 'Campaign Title',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            c['status'] ?? 'Sent',
                            style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.roseAccent, size: 18),
                          onPressed: () => _deleteCampaign(c['id']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c['message'] ?? '', style: GoogleFonts.inter(color: AppColors.slate300, fontSize: 11)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _metricBadge('Recipients', '${c['recipient_count'] ?? 0} Clients'),
                        _metricBadge('Open Rate', '${c['open_rate_pct'] ?? 80}%'),
                        _metricBadge('Click Rate', '${c['click_rate_pct'] ?? 40}%'),
                        if (c['attached_discount_code'] != null)
                          _metricBadge('Promo Attached', c['attached_discount_code']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: channels.map((ch) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.slate900,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.limitlessGold.withOpacity(0.3)),
                          ),
                          child: Text(
                            ch.toUpperCase().replaceAll('_', ' '),
                            style: GoogleFonts.inter(fontSize: 9, color: AppColors.limitlessGold, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _metricBadge(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $val', style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 10)),
    );
  }
}
