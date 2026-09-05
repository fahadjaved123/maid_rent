import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      await auth.refreshUser();
      if (!mounted) return;
      _navigateAfterAuth(auth);
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  Future<void> _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      await auth.refreshUser();
      if (!mounted) return;
      _navigateAfterAuth(auth);
    }
  }

  Future<void> _facebookLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithFacebook();
    if (success && mounted) {
      await auth.refreshUser();
      if (!mounted) return;
      _navigateAfterAuth(auth);
    }
  }

  void _navigateAfterAuth(AuthProvider auth) {
    if (auth.userModel == null) {
      Navigator.pushReplacementNamed(context, '/role-selection');
      return;
    }
    if (auth.userModel!.role == UserRole.maid) {
      Navigator.pushReplacementNamed(context, '/maid/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/household/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                const Text(
                  'Welcome Back 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: 'Sign In',
                      onPressed: _login,
                      isLoading: auth.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.dividerColor)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In
                SocialLoginButton(
                  text: 'Continue with Google',
                  iconPath: 'google',
                  onPressed: _googleLogin,
                ),
                const SizedBox(height: 12),

                // Facebook Sign In
                SocialLoginButton(
                  text: 'Continue with Facebook',
                  iconPath: 'facebook',
                  onPressed: _facebookLogin,
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 32),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, '/register'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.isNotEmpty) {
                final auth = context.read<AuthProvider>();
                await auth.resetPassword(emailCtrl.text.trim());
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
