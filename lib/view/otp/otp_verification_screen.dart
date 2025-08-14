// otp_verification_screen.dart (updated)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:ecom_innerix/view_model/otp_vm.dart';

class OtpLoginScreen extends StatefulWidget {
  final String email;
  final String provider;

  const OtpLoginScreen({
    super.key,
    required this.email,
    this.provider = 'Google',
  });

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  int resendCountdown = 0;
  Timer? resendTimer;

  @override
  void initState() {
    super.initState();
    print("=== OTP SCREEN INIT ===");
    print("Email: ${widget.email}");
    print("Provider: ${widget.provider}");
    
    // Automatically request OTP when screen loads
    _requestInitialOtp();
    _startResendCountdown();
  }

  Future<void> _requestInitialOtp() async {
    final otpViewModel = Provider.of<OtpViewModel>(context, listen: false);
    
    setState(() {
      isLoading = true;
    });
    
    final success = await otpViewModel.requestOtp(widget.email);
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      
      if (!success) {
        _showErrorMessage(otpViewModel.errorMessage ?? 'Failed to send OTP');
      } else {
        _showSuccessMessage('OTP sent to ${widget.email}');
      }
    }
  }

  void _startResendCountdown() {
    setState(() {
      resendCountdown = 60;
    });
    
    resendTimer?.cancel();
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (resendCountdown > 0) {
            resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    "Let's verify\nYour ${widget.provider} Account",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle with email
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Enter the OTP code we sent to '),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: '. Need to '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'edit the email',
                              style: TextStyle(
                                color: Color(0xFF1976D2),
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '?'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // OTP Input Field
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: otpController,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Enter your OTP',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Resend code section
                  Center(
                    child: resendCountdown > 0
                        ? Text(
                            'Resend code in (00:${resendCountdown.toString().padLeft(2, '0')})',
                            style: const TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : TextButton(
                            onPressed: isLoading ? null : _resendOtp,
                            child: Text(
                              'Resend Code',
                              style: TextStyle(
                                color: isLoading ? Colors.grey : const Color(0xFF1976D2),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Verify OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _canVerify() && !isLoading ? _verifyOtp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canVerify() {
    return otpController.text.length == 6;
  }

  Future<void> _verifyOtp() async {
    if (!_canVerify()) return;

    final otpViewModel = Provider.of<OtpViewModel>(context, listen: false);
    
    setState(() {
      isLoading = true;
    });
    
    final success = await otpViewModel.verifyOtp(widget.email, otpController.text);
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      
      if (success) {
        _showSuccessMessage('OTP verified successfully!');
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _resendOtp() async {
    final otpViewModel = Provider.of<OtpViewModel>(context, listen: false);
    
    setState(() {
      isLoading = true;
    });
    
    otpController.clear();
    final success = await otpViewModel.requestOtp(widget.email);
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      
      if (success) {
        _startResendCountdown();
        _showSuccessMessage('OTP sent successfully!');
      }
    }
  }

  @override
  void dispose() {
    print("=== OTP SCREEN DISPOSE ===");
    otpController.dispose();
    resendTimer?.cancel();
    super.dispose();
  }
}