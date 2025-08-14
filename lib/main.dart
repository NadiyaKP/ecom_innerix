import 'package:ecom_innerix/view_model/signup_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/onboarding/onboarding_screen.dart';
import 'view_model/login_vm.dart';
import 'view_model/otp_vm.dart';
import 'view_model/home_vm.dart';

void main() {
  runApp(const EcomInnerixApp());
}

class EcomInnerixApp extends StatelessWidget {
  const EcomInnerixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => OtpViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
      ],
      child: MaterialApp(
        title: 'Ecom Innerix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: const OnboardingScreen(), 
      ),
    );
  }
}

