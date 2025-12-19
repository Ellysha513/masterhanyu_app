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
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                color: Colors.black.withValues(alpha: 0.12),
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2B3C),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Sign in to continue learning Chinese!",
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),

                              const SizedBox(height: 25),

                              TextField(
                                controller: usernameController,
                                decoration: _input(
                                  "Username",
                                  Icons.person_outline,
                                ),
                              ),

                              const SizedBox(height: 18),

                              TextField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: _input(
                                  "Password",
                                  Icons.lock_outline,
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
                                    backgroundColor: const Color(0xFF0A4D68),
                                    disabledBackgroundColor:
                                        Colors.grey.shade400,
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
                                              color: Colors.white,
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
                                      color: Color(0xFF0A4D68),
                                      fontWeight: FontWeight.bold,
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

  InputDecoration _input(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }
}
