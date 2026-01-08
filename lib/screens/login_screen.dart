import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../widgets/cat_typing_video.dart';
import '../widgets/animated_background.dart';
import '../services/supabase_auth_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool isFormValid = false;

  void validateForm() {
    setState(() {
      isFormValid =
          usernameController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    usernameController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final auth = SupabaseAuthService();

      final response = await auth.signInWithUsername(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      debugPrint('SESSION = ${response.session}');

      if (!mounted) return;

      setState(() => loading = false);

      if (response.session == null) {
        throw Exception('Login failed');
      }

      // ✅ MANUAL NAVIGATION (NO MORE WAITING)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootApp()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF9F8EF1);
    const headline = Color(0xFF0F172A);
    const muted = Color(0xFF6B7280);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CatTypingVideo(),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(26),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                color: Colors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: primary,
                                    child: Icon(
                                      Icons.pets,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'MasterHanyu',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: headline,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: headline,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Sign in to continue learning Chinese!",
                                style: TextStyle(color: muted, fontSize: 15),
                              ),

                              const SizedBox(height: 25),

                              TextField(
                                controller: usernameController,
                                decoration: _input(
                                  "Username",
                                  Icons.person_outline,
                                  primary,
                                ),
                              ),

                              const SizedBox(height: 18),

                              TextField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: _input(
                                  "Password",
                                  Icons.lock_outline,
                                  primary,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _obscurePassword =
                                                  !_obscurePassword,
                                        ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      (!isFormValid || loading) ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    disabledBackgroundColor: primary
                                        .withValues(alpha: 0.35),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      loading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Don't have an account? Sign Up",
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _input(
    String hint,
    IconData icon,
    Color accent, {
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: accent),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFF6F9FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent, width: 1.4),
      ),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
