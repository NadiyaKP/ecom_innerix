import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/theme.dart';
import '../../view_model/login_vm.dart';
import '../../view_model/otp_vm.dart';
import '../home/home_screen.dart';
import '../otp/otp_verification_screen.dart';
import './signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isGoogleLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingLarge,
            vertical: AppTheme.paddingXXLarge,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: AppTheme.paddingXXLarge),

                // Email Field
                _buildEmailField(),
                const SizedBox(height: AppTheme.paddingLarge),

                // Password Field
                _buildPasswordField(),
                const SizedBox(height: AppTheme.paddingMedium),

                // Forgot Password
                _buildForgotPasswordButton(),
                const SizedBox(height: AppTheme.paddingLarge),

                // Login Button
                Consumer<LoginViewModel>(
                  builder: (context, loginVM, _) {
                    return _buildLoginButton(loginVM);
                  },
                ),
                const SizedBox(height: AppTheme.paddingXLarge),

                // Divider
                _buildOrDivider(),
                const SizedBox(height: AppTheme.paddingLarge),

                // Google Login Button
                _buildGoogleLoginButton(),
                const SizedBox(height: AppTheme.paddingMedium),

                // Facebook Login Button
                _buildFacebookLoginButton(),
                const SizedBox(height: AppTheme.paddingXXLarge),

                // Sign Up Link
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign in to your\nAccount',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter your email and password to log in',
          style: AppTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: AppTheme.getInputDecoration(
            hintText: 'Enter your email',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        TextFormField(
          controller: passwordController,
          obscureText: !_isPasswordVisible,
          decoration: AppTheme.getInputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
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
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showForgotPasswordDialog(context),
        child: const Text(
          'Forgot Password?',
          style: AppTheme.linkText,
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel loginVM) {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.buttonHeight,
      child: ElevatedButton(
        onPressed: loginVM.isLoading || _isGoogleLoading
            ? null
            : () => _handleLogin(loginVM),
        style: AppTheme.primaryButtonStyle,
        child: loginVM.isLoading
            ? AppTheme.loadingIndicator
            : const Text(
                'Log In',
                style: AppTheme.buttonText,
              ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.textSecondaryColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
          child: Text(
            'Or',
            style: TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.textSecondaryColor)),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.buttonHeight,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
        style: AppTheme.outlinedButtonStyle,
        child: _isGoogleLoading
            ? AppTheme.loadingIndicatorDark
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/login/google.png',
                    height: AppTheme.iconSize,
                    width: AppTheme.iconSize,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: AppTheme.socialButtonText,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFacebookLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.buttonHeight,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : () => _handleSocialLogin('Facebook'),
        style: AppTheme.outlinedButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/login/facebook.png',
              height: AppTheme.iconSize,
              width: AppTheme.iconSize,
              errorBuilder: (_, __, ___) => Container(
                height: AppTheme.iconSize,
                width: AppTheme.iconSize,
                decoration: const BoxDecoration(
                  color: AppTheme.facebookColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.facebook,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Facebook',
              style: AppTheme.socialButtonText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        TextButton(
          onPressed: _isGoogleLoading ? null : () => _navigateToSignUp(),
          child: Text(
            'Sign Up',
            style: _isGoogleLoading 
                ? TextStyle(color: AppTheme.textSecondaryColor)
                : AppTheme.signUpLinkText,
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin(LoginViewModel loginVM) async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final success = await loginVM.loginWithPassword(email, password);
    
    if (success && mounted) {
      // Pass the email to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userEmail: email), // Pass email here
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final otpVM = Provider.of<OtpViewModel>(context, listen: false);
      final success = await otpVM.requestOtp(googleUser.email);

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpLoginScreen(
              email: googleUser.email,
              provider: 'Google',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send OTP. Please try again."),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In failed: ${error.toString()}"),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$provider login coming soon!"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive reset instructions:'),
            const SizedBox(height: AppTheme.paddingMedium),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtpLoginScreen(
                    email: emailController.text.trim(),
                    provider: 'Email',
                  ),
                ),
              );
            },
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }
}