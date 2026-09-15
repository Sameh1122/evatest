import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final AppState state;

  const ProfilePage({Key? key, required this.state}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final medicationCtrl = TextEditingController();

  String selectedGender = 'Male';
  String selectedActivity = 'Moderate';

  final Map<String, bool> chronicDiseasesMap = {
    'Hypertension / High Blood Pressure': true,
    'Kidney / Renal Disease': true,
    'Diabetes (Type 1 or 2)': false,
    'Autoimmune Disorder': false,
    'Gallbladder / Bile Stones': false,
    'Heart Disease': false,
  };

  final Map<String, bool> allergiesMap = {
    'Seafood / Shellfish': true,
    'Dairy / Whey Protein': false,
    'Peanuts / Tree Nuts': true,
    'Gluten': false,
  };

  final Map<String, bool> goalsMap = {
    'Heart Health': true,
    'Muscle Recovery': true,
    'Joint Mobility': true,
    'Sleep Quality': false,
    'Immune Defense': false,
    'Stress & Cortisol Balance': false,
  };

  @override
  void initState() {
    super.initState();
    final profile = widget.state.clientProfile;
    final user = widget.state.currentUser;

    if (user != null) {
      nameCtrl.text = user.name;
    }

    if (profile != null) {
      ageCtrl.text = profile.age.toString();
      heightCtrl.text = profile.heightCm.toString();
      weightCtrl.text = profile.weightKg.toString();
      medicationCtrl.text = profile.medicationNotes;
      selectedGender = profile.gender.isNotEmpty ? profile.gender : 'Male';
      selectedActivity = profile.activityLevel.isNotEmpty ? profile.activityLevel : 'Moderate';

      for (var key in chronicDiseasesMap.keys) {
        chronicDiseasesMap[key] = profile.chronicDiseases.toLowerCase().contains(key.split(' ')[0].toLowerCase());
      }
      for (var key in goalsMap.keys) {
        goalsMap[key] = profile.healthGoals.toLowerCase().contains(key.split(' ')[0].toLowerCase());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emeraldAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined, color: AppColors.emeraldAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client Health Profiling & Medical History',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Personalize your wellness goals and backhistory chronic conditions for smart vitamin proposals.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      title: '1. Basic Personal Data',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _field('Full Name', nameCtrl, Icons.person)),
                              const SizedBox(width: 16),
                              Expanded(child: _field('Age (Years)', ageCtrl, Icons.cake, isNum: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _dropdown('Gender', selectedGender, ['Male', 'Female', 'Other'], (val) {
                                  if (val != null) setState(() => selectedGender = val);
                                }),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _field('Height (cm)', heightCtrl, Icons.height, isNum: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _field('Weight (kg)', weightCtrl, Icons.monitor_weight, isNum: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _dropdown('Activity Level', selectedActivity, ['Sedentary', 'Light Active', 'Moderate', 'Very Active'], (val) {
                            if (val != null) setState(() => selectedActivity = val);
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _sectionCard(
                      title: '2. Medical History & Chronic Conditions',
                      icon: Icons.medical_information_outlined,
                      accentColor: AppColors.amberAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select any diagnosed chronic conditions to enable safety contraindication warnings:',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate300),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: chronicDiseasesMap.keys.map((condition) {
                              final isChecked = chronicDiseasesMap[condition]!;
                              return FilterChip(
                                selected: isChecked,
                                label: Text(condition),
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isChecked ? Colors.black : Colors.white,
                                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                                ),
                                backgroundColor: AppColors.slate900,
                                selectedColor: AppColors.amberAccent,
                                onSelected: (val) {
                                  setState(() => chronicDiseasesMap[condition] = val);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          _field('Current Daily Medications & Physician Notes', medicationCtrl, Icons.note_alt_outlined, maxLines: 2),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _sectionCard(
                      title: '3. Allergies & Targeted Health Goals',
                      icon: Icons.track_changes_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Known Allergies:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: allergiesMap.keys.map((allergy) {
                              final isChecked = allergiesMap[allergy]!;
                              return FilterChip(
                                selected: isChecked,
                                label: Text(allergy),
                                labelStyle: GoogleFonts.inter(fontSize: 12, color: isChecked ? Colors.black : Colors.white),
                                backgroundColor: AppColors.slate900,
                                selectedColor: AppColors.roseAccent,
                                onSelected: (val) => setState(() => allergiesMap[allergy] = val),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text('Primary Health & Vitality Goals:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: goalsMap.keys.map((goal) {
                              final isChecked = goalsMap[goal]!;
                              return FilterChip(
                                selected: isChecked,
                                label: Text(goal),
                                labelStyle: GoogleFonts.inter(fontSize: 12, color: isChecked ? Colors.black : Colors.white),
                                backgroundColor: AppColors.slate900,
                                selectedColor: AppColors.emeraldAccent,
                                onSelected: (val) => setState(() => goalsMap[goal] = val),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save, color: Colors.black),
                      label: Text('Save & Update Health Profile', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emeraldAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.emeraldAccent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'AI Vitamin Proposals',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Based on your active profile metrics and chronic history:',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate400),
                      ),
                      const SizedBox(height: 16),

                      if (widget.state.recommendations.isEmpty)
                        Text('Save profile to view personalized vitamin recommendations.', style: GoogleFonts.inter(color: AppColors.slate400))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.state.recommendations.length.clamp(0, 3),
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final rec = widget.state.recommendations[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.slate900,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.slate700),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rec.product.name,
                                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.emeraldAccent.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Match: ${rec.score} pts',
                                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.emeraldAccent, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (rec.matchReasons.isNotEmpty)
                                    Text(
                                      'Reason: ${rec.matchReasons.first}',
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate300),
                                    ),
                                  if (rec.warnings.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      rec.warnings.first,
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.amberAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child, Color accentColor = AppColors.emeraldAccent}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.slate400),
        prefixIcon: Icon(icon, color: AppColors.slate400, size: 18),
        filled: true,
        fillColor: AppColors.slate900,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.slate700)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.emeraldAccent)),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.slate900,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.slate400),
        filled: true,
        fillColor: AppColors.slate900,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.slate700)),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  void _saveProfile() async {
    final activeDiseases = chronicDiseasesMap.entries.where((e) => e.value).map((e) => e.key).join(', ');
    final activeAllergies = allergiesMap.entries.where((e) => e.value).map((e) => e.key).join(', ');
    final activeGoals = goalsMap.entries.where((e) => e.value).map((e) => e.key).join(', ');

    await widget.state.updateHealthProfile({
      'name': nameCtrl.text,
      'age': int.tryParse(ageCtrl.text) ?? 30,
      'gender': selectedGender,
      'height_cm': double.tryParse(heightCtrl.text) ?? 170.0,
      'weight_kg': double.tryParse(weightCtrl.text) ?? 70.0,
      'activity_level': selectedActivity,
      'chronic_diseases': activeDiseases.isNotEmpty ? activeDiseases : 'None',
      'allergies': activeAllergies.isNotEmpty ? activeAllergies : 'None',
      'health_goals': activeGoals.isNotEmpty ? activeGoals : 'General Wellness',
      'medication_notes': medicationCtrl.text,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health Profile & Chronic History saved! Smart proposals refreshed.'),
          backgroundColor: AppColors.emeraldAccent,
        ),
      );
    }
  }
}
