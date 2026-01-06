import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/cat_typing_video.dart';
import '../widgets/animated_background.dart';
import '../services/supabase_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool _obscurePassword = true;
  bool isFormValid = false;

  void validateForm() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    setState(() {
      isFormValid =
          emailRegex.hasMatch(emailController.text.trim()) &&
          usernameController.text.trim().isNotEmpty &&
          passwordController.text.trim().length >= 6;
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateForm);
    usernameController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  Future<void> signup() async {
    setState(() => loading = true);
    final auth = SupabaseAuthService();

    try {
      final response = await auth.signUp(
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => loading = false);

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
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
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CatTypingVideo(),
                        const SizedBox(height: 12),

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
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2B3C),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Register to start learning Chinese!",
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),

                              const SizedBox(height: 25),

                              _field(
                                emailController,
                                "Email",
                                Icons.email_outlined,
                              ),
                              const SizedBox(height: 18),
                              _field(
                                usernameController,
                                "Username",
                                Icons.person_outline,
                              ),
                              const SizedBox(height: 18),
                              _field(
                                passwordController,
                                "Password",
                                Icons.lock_outline,
                                obscure: true,
                              ),

                              const SizedBox(height: 25),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      (!isFormValid || loading) ? null : signup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5C56D6),
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
                                            "Create Account",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "I'm already registered",
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

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure ? _obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        helperText: obscure ? 'Min 6 characters' : null,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            obscure
                ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                )
                : null,
      ),
    );
  }
}
