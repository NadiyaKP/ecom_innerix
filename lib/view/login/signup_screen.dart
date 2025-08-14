import 'package:ecom_innerix/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/signup_vm.dart';
import '../../core/constants/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final shopIdController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupViewModel>(
      builder: (context, signupVM, child) {
        // Show error/success snackbar when occurs
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (signupVM.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(signupVM.errorMessage!),
                backgroundColor: AppTheme.errorColor,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: AppTheme.backgroundColor,
                  onPressed: () {
                    signupVM.clearError();
                  },
                ),
              ),
            );
          }
          
          if (signupVM.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(signupVM.successMessage!),
                backgroundColor: AppTheme.successColor,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: AppTheme.backgroundColor,
                  onPressed: () {
                    signupVM.clearSuccess();
                  },
                ),
              ),
            );
          }
        });

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.paddingXXLarge),
                      
                      // Back button
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium + AppTheme.paddingSmall),
                      
                      // Title
                      const Text(
                        'Create your\nAccount',
                        style: AppTheme.headingLarge,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      const Text(
                        'Please enter your details to create account',
                        style: AppTheme.bodyLarge,
                      ),
                      
                      const SizedBox(height: AppTheme.paddingXLarge),
                      
                      // Name Field
                      _buildInputField(
                        label: 'Full Name',
                        controller: nameController,
                        hintText: 'Enter your full name',
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium + AppTheme.paddingSmall),
                      
                      // Email Field
                      _buildInputField(
                        label: 'Email',
                        controller: emailController,
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium + AppTheme.paddingSmall),
                      
                      // Phone Field
                      _buildInputField(
                        label: 'Phone Number',
                        controller: phoneController,
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium + AppTheme.paddingSmall),
                      
                      // Shop ID Field
                      _buildInputField(
                        label: 'Shop ID',
                        controller: shopIdController,
                        hintText: 'Enter shop ID',
                        keyboardType: TextInputType.number,
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium + AppTheme.paddingSmall),
                      
                      // Password Field
                      _buildPasswordField(
                        label: 'Password',
                        controller: passwordController,
                        hintText: 'Enter your password',
                        isVisible: _isPasswordVisible,
                        onToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium + AppTheme.paddingSmall),
                      
                      // Confirm Password Field
                      _buildPasswordField(
                        label: 'Confirm Password',
                        controller: confirmPasswordController,
                        hintText: 'Confirm your password',
                        isVisible: _isConfirmPasswordVisible,
                        onToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      
                      const SizedBox(height: AppTheme.paddingLarge),
                      
                      // Terms and Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                            checkColor: AppTheme.backgroundColor,
                          ),
                          const SizedBox(width: AppTheme.paddingSmall),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptTerms = !_acceptTerms;
                                });
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: AppTheme.linkText,
                                  children: [
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(color: AppTheme.textSecondaryColor),
                                    ),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyle(color: AppTheme.textSecondaryColor),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.paddingXLarge),
                      
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: AppTheme.buttonHeight,
                        child: ElevatedButton(
                          onPressed: (signupVM.isLoading || !_acceptTerms) ? null : _handleSignup,
                          style: AppTheme.primaryButtonStyle,
                          child: signupVM.isLoading
                              ? AppTheme.loadingIndicator
                              : const Text(
                                  'Create Account',
                                  style: AppTheme.buttonText,
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.paddingXLarge),
                      
                      // Or divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.textSecondaryColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
                            child: Text(
                              'Or',
                              style: AppTheme.bodyLarge,
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.textSecondaryColor)),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.paddingLarge),
                      
                      // Google Signup Button
                      _buildSocialButton(
                        icon: 'assets/images/login/google.png',
                        text: 'Continue with Google',
                        onPressed: signupVM.isLoading ? null : _handleGoogleSignup,
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium),
                      
                      // Facebook Signup Button
                      _buildSocialButton(
                        icon: 'assets/images/login/facebook.png',
                        text: 'Continue with Facebook',
                        onPressed: signupVM.isLoading ? null : () => _handleSocialSignup('Facebook'),
                        fallbackIcon: const Icon(Icons.facebook, color: AppTheme.backgroundColor, size: AppTheme.paddingMedium),
                        fallbackColor: AppTheme.facebookColor,
                      ),
                      
                      const SizedBox(height: AppTheme.paddingXXLarge),
                      
                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: AppTheme.textSecondaryColor),
                          ),
                          TextButton(
                            onPressed: signupVM.isLoading ? null : () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Sign In',
                              style: AppTheme.signUpLinkText,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimaryColor,
          ),
          decoration: AppTheme.getInputDecoration(hintText: hintText),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimaryColor,
          ),
          decoration: AppTheme.getInputDecoration(
            hintText: hintText,
            suffixIcon: IconButton(
              icon: Icon(
                isVisible 
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
                color: AppTheme.textSecondaryColor,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String text,
    VoidCallback? onPressed,
    Widget? fallbackIcon,
    Color? fallbackColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: AppTheme.outlinedButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: AppTheme.iconSize,
              width: AppTheme.iconSize,
              errorBuilder: (context, error, stackTrace) {
                if (fallbackIcon != null && fallbackColor != null) {
                  return Container(
                    height: AppTheme.iconSize,
                    width: AppTheme.iconSize,
                    decoration: BoxDecoration(
                      color: fallbackColor,
                      shape: BoxShape.circle,
                    ),
                    child: fallbackIcon,
                  );
                }
                return const Icon(Icons.g_mobiledata, size: AppTheme.paddingLarge);
              },
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: AppTheme.socialButtonText,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final shopId = shopIdController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || phone.isEmpty || shopId.isEmpty || 
        password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit phone number"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters long"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms & Conditions"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final signupVM = Provider.of<SignupViewModel>(context, listen: false);
    
    try {
      final success = await signupVM.signupUser(
        name: name,
        email: email,
        phone: phone,
        shopId: shopId,
        password: password,
      );
      
      if (success && mounted) {
        // Clear form
        _clearForm();
        
        // Navigate to OTP screen for verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unexpected error: ${e.toString()}"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _handleGoogleSignup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Google signup coming soon!"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleSocialSignup(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$provider signup coming soon!"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    shopIdController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    setState(() {
      _acceptTerms = false;
      _isPasswordVisible = false;
      _isConfirmPasswordVisible = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    shopIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}