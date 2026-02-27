// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/validators.dart';
import '../auth_provider.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: AppTheme.primary, size: 30),
                ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(
                  'Welcome back!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue to TaskFlow',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 36),
                if (auth.errorMessage != null)
                  ErrorBanner(message: auth.errorMessage!)
                      .animate()
                      .shake(hz: 3),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefix: const Icon(Icons.email_outlined, size: 20),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  prefix: const Icon(Icons.lock_outline, size: 20),
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: auth.isLoading,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.register),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}