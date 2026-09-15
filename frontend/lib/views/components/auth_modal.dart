import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';

class AuthModal extends StatefulWidget {
  final AppState state;

  const AuthModal({Key? key, required this.state}) : super(key: key);

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  bool isLogin = true;
  final emailCtrl = TextEditingController(text: 'client@nutripulse.com');
  final passwordCtrl = TextEditingController(text: 'client123');
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  String selectedRole = 'client';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.slate900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.emeraldAccent.withOpacity(0.3)),
      ),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isLogin ? 'Sign In to NutriPulse' : 'Create Account',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.slate500),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isLogin ? 'Access your personalized health profile & supplement orders' : 'Join as a Client, Admin, or Distributor',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
            ),
            const SizedBox(height: 20),

            if (widget.state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.roseAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.roseAccent.withOpacity(0.4)),
                ),
                child: Text(
                  widget.state.errorMessage!,
                  style: GoogleFonts.inter(color: AppColors.roseAccent, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (!isLogin) ...[
              _inputField('Full Name', nameCtrl, Icons.person_outline),
              const SizedBox(height: 12),
              _inputField('Phone Number', phoneCtrl, Icons.phone_outlined),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: AppColors.slate800,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  labelStyle: GoogleFonts.inter(color: AppColors.slate400),
                  filled: true,
                  fillColor: AppColors.slate800,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'client', child: Text('Client (Customer)')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin (Store Manager)')),
                  DropdownMenuItem(value: 'distributor', child: Text('Distributor (Delivery Logistics)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedRole = val);
                },
              ),
              const SizedBox(height: 12),
            ],

            _inputField('Email Address', emailCtrl, Icons.email_outlined),
            const SizedBox(height: 12),
            _inputField('Password', passwordCtrl, Icons.lock_outline, obscure: true),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: widget.state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: widget.state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text(
                      isLogin ? 'Sign In' : 'Register Account',
                      style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),

            const SizedBox(height: 16),

            Text(
              'OR QUICK LOGIN AS DEMO USER:',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _quickBtn('Client', 'client@nutripulse.com', 'client123'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _quickBtn('Admin', 'admin@nutripulse.com', 'admin123'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _quickBtn('Distributor', 'distributor@nutripulse.com', 'dist123'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? "Don't have an account? " : "Already have an account? ",
                  style: GoogleFonts.inter(color: AppColors.slate400, fontSize: 13),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? 'Register Now' : 'Sign In',
                    style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.slate400),
        prefixIcon: Icon(icon, color: AppColors.slate400, size: 20),
        filled: true,
        fillColor: AppColors.slate800,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.slate700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.emeraldAccent),
        ),
      ),
    );
  }

  Widget _quickBtn(String label, String email, String password) {
    return OutlinedButton(
      onPressed: () async {
        emailCtrl.text = email;
        passwordCtrl.text = password;
        await widget.state.login(email, password);
        if (widget.state.currentUser != null && mounted) {
          Navigator.pop(context);
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.slate700),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(color: AppColors.emeraldAccent, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _submit() async {
    if (isLogin) {
      await widget.state.login(emailCtrl.text, passwordCtrl.text);
    } else {
      await widget.state.register(
        name: nameCtrl.text,
        email: emailCtrl.text,
        password: passwordCtrl.text,
        role: selectedRole,
        phone: phoneCtrl.text,
      );
    }
    if (widget.state.currentUser != null && mounted) {
      Navigator.pop(context);
    }
  }
}
