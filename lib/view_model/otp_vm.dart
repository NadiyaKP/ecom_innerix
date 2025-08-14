import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpViewModel extends ChangeNotifier {
  final _baseUrl = "https://app.ecominnerix.com/api";
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Request OTP for the given email
  Future<bool> requestOtp(String email) async {
    final url = Uri.parse("$_baseUrl/request-otp");
    
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
        }),
      );
      
      _setLoading(false);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          debugPrint("OTP request successful: ${responseData['message']}");
          // For debugging purposes, you can print the OTP (remove in production)
          debugPrint("Generated OTP: ${responseData['otp']}");
          return true;
        } else {
          _setError(responseData['message'] ?? 'Failed to send OTP');
          return false;
        }
      } else {
        final errorData = jsonDecode(response.body);
        _setError(errorData['message'] ?? 'Failed to send OTP');
        debugPrint("OTP request failed: ${response.body}");
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError("Network error. Please check your connection.");
      debugPrint("Error during OTP request: $e");
      return false;
    }
  }

  /// Verify OTP for the given email and OTP code
  Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse("$_baseUrl/verify-email-otp");
    
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      );
      
      _setLoading(false);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          debugPrint("OTP verification successful");
          // Save token if provided in response
          if (responseData.containsKey('token')) {
            // You can save the token to shared preferences here
            debugPrint("Token received: ${responseData['token']}");
          }
          return true;
        } else {
          _setError(responseData['message'] ?? 'Invalid OTP');
          return false;
        }
      } else {
        final errorData = jsonDecode(response.body);
        _setError(errorData['message'] ?? 'Invalid OTP');
        debugPrint("OTP verification failed: ${response.body}");
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError("Network error. Please check your connection.");
      debugPrint("Error during OTP verification: $e");
      return false;
    }
  }
}