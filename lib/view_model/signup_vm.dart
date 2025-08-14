import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SignupViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // API endpoint
  static const String _baseUrl = 'https://app.ecominnerix.com/api';
  static const String _signupEndpoint = '/register';

  /// Create HTTP client with custom SSL configuration
  http.Client _createHttpClient() {
    final HttpClient httpClient = HttpClient();
    
    // Option 1: Accept all certificates (NOT recommended for production)
    // Only use this for development/testing
    if (kDebugMode) {
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
        print('DEBUG [SignupViewModel]: Accepting certificate for $host:$port');
        return true; // Accept all certificates in debug mode
      };
    } else {
      // Option 2: For production, you might want to pin specific certificates
      // or implement proper certificate validation
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // You can implement custom certificate validation here
        // For now, we'll accept the certificate if it matches your domain
        if (host == 'app.ecominnerix.com') {
          print('DEBUG [SignupViewModel]: Accepting certificate for trusted domain: $host');
          return true;
        }
        return false;
      };
    }

    // Configure connection timeout
    httpClient.connectionTimeout = const Duration(seconds: 30);
    
    return IOClient(httpClient);
  }

  /// Signup user with email and other details
  Future<bool> signupUser({
    required String name,
    required String email,
    required String phone,
    required String shopId,
    required String password,
  }) async {
    print('DEBUG [SignupViewModel]: Starting signup process');
    print('DEBUG [SignupViewModel]: Input parameters:');
    print('  - Name: "$name"');
    print('  - Email: "$email"');
    print('  - Phone: "$phone"');
    print('  - Shop ID: "$shopId"');
    print('  - Password length: ${password.length}');
    
    _setLoading(true);
    _clearMessages();
    print('DEBUG [SignupViewModel]: Loading state set to true, messages cleared');

    // Create custom HTTP client
    final client = _createHttpClient();

    try {
      final url = Uri.parse('$_baseUrl$_signupEndpoint');
      print('DEBUG [SignupViewModel]: Full URL: $url');
      
      // Prepare request body
      final requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'shop_id': shopId,
        'phone_number': phone,
      };

      print('DEBUG [SignupViewModel]: Request body prepared:');
      print('  - name: ${requestBody['name']}');
      print('  - email: ${requestBody['email']}');
      print('  - shop_id: ${requestBody['shop_id']}');
      print('  - phone_number: ${requestBody['phone_number']}');
      print('  - password: [HIDDEN - length: ${requestBody['password'].toString().length}]');

      print('DEBUG [SignupViewModel]: Making HTTP POST request with custom SSL handling...');
      
      // Make API call with custom client
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Flutter App v1.0', // Add user agent
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('DEBUG [SignupViewModel]: Request timed out after 30 seconds');
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print('DEBUG [SignupViewModel]: HTTP response received');
      print('  - Status Code: ${response.statusCode}');
      print('  - Status Message: ${response.reasonPhrase}');
      print('  - Response Headers: ${response.headers}');
      print('  - Response Body Length: ${response.body.length}');
      print('  - Response Body: ${response.body}');

      // Parse response
      final Map<String, dynamic> responseData;
      try {
        print('DEBUG [SignupViewModel]: Attempting to parse JSON response...');
        responseData = jsonDecode(response.body);
        print('DEBUG [SignupViewModel]: JSON parsed successfully: $responseData');
      } catch (e) {
        print('DEBUG [SignupViewModel]: JSON parsing failed: $e');
        print('DEBUG [SignupViewModel]: Raw response body: "${response.body}"');
        throw Exception('Invalid response format from server');
      }

      // Handle different status codes
      print('DEBUG [SignupViewModel]: Processing response based on status code...');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('DEBUG [SignupViewModel]: Success status code received (200/201)');
        
        // Success response
        if (responseData['status'] == true) {
          final successMsg = responseData['message'] ?? 'User registered successfully';
          print('DEBUG [SignupViewModel]: Registration successful - Status: true');
          print('DEBUG [SignupViewModel]: Success message: "$successMsg"');
          _setSuccessMessage(successMsg);
          _setLoading(false);
          print('DEBUG [SignupViewModel]: Returning true (success)');
          return true;
        } else {
          // API returned status false
          final errorMsg = responseData['message'] ?? 'Registration failed';
          print('DEBUG [SignupViewModel]: Registration failed - API returned status: false');
          print('DEBUG [SignupViewModel]: Error message: "$errorMsg"');
          print('DEBUG [SignupViewModel]: Full response data: $responseData');
          _setErrorMessage(errorMsg);
          _setLoading(false);
          print('DEBUG [SignupViewModel]: Returning false (API status false)');
          return false;
        }
      } else if (response.statusCode == 422) {
        print('DEBUG [SignupViewModel]: Validation error (422) received');
        
        // Validation errors
        if (responseData.containsKey('errors')) {
          print('DEBUG [SignupViewModel]: Processing validation errors...');
          final errors = responseData['errors'] as Map<String, dynamic>;
          print('DEBUG [SignupViewModel]: Errors object: $errors');
          
          final errorMessages = <String>[];
          
          errors.forEach((field, messages) {
            print('DEBUG [SignupViewModel]: Processing field "$field" with messages: $messages');
            if (messages is List) {
              errorMessages.addAll(messages.cast<String>());
            } else if (messages is String) {
              errorMessages.add(messages);
            }
          });
          
          final finalErrorMsg = errorMessages.join('\n');
          print('DEBUG [SignupViewModel]: Compiled error messages: "$finalErrorMsg"');
          _setErrorMessage(finalErrorMsg);
        } else {
          final errorMsg = responseData['message'] ?? 'Validation failed';
          print('DEBUG [SignupViewModel]: No errors field found, using message: "$errorMsg"');
          _setErrorMessage(errorMsg);
        }
        _setLoading(false);
        print('DEBUG [SignupViewModel]: Returning false (validation error)');
        return false;
      } else if (response.statusCode == 409) {
        print('DEBUG [SignupViewModel]: Conflict error (409) - user already exists');
        
        // Conflict - user already exists
        final errorMsg = responseData['message'] ?? 'User already exists with this email';
        print('DEBUG [SignupViewModel]: Conflict message: "$errorMsg"');
        _setErrorMessage(errorMsg);
        _setLoading(false);
        print('DEBUG [SignupViewModel]: Returning false (conflict)');
        return false;
      } else if (response.statusCode >= 500) {
        print('DEBUG [SignupViewModel]: Server error (${response.statusCode}) received');
        print('DEBUG [SignupViewModel]: Server error response: $responseData');
        
        // Server error
        _setErrorMessage('Server error. Please try again later.');
        _setLoading(false);
        print('DEBUG [SignupViewModel]: Returning false (server error)');
        return false;
      } else {
        print('DEBUG [SignupViewModel]: Unexpected status code: ${response.statusCode}');
        print('DEBUG [SignupViewModel]: Response data: $responseData');
        
        // Other errors
        final errorMsg = responseData['message'] ?? 'Registration failed. Please try again.';
        print('DEBUG [SignupViewModel]: Other error message: "$errorMsg"');
        _setErrorMessage(errorMsg);
        _setLoading(false);
        print('DEBUG [SignupViewModel]: Returning false (other error)');
        return false;
      }
    } on SocketException catch (e) {
      print('DEBUG [SignupViewModel]: SocketException caught: $e');
      _setErrorMessage('No internet connection. Please check your network.');
      _setLoading(false);
      print('DEBUG [SignupViewModel]: Returning false (socket exception)');
      return false;
    } on HandshakeException catch (e) {
      print('DEBUG [SignupViewModel]: HandshakeException caught: $e');
      _setErrorMessage('SSL certificate error. Please check your connection or try again later.');
      _setLoading(false);
      print('DEBUG [SignupViewModel]: Returning false (handshake exception)');
      return false;
    } on TlsException catch (e) {
      print('DEBUG [SignupViewModel]: TlsException caught: $e');
      _setErrorMessage('Secure connection failed. Please try again.');
      _setLoading(false);
      print('DEBUG [SignupViewModel]: Returning false (TLS exception)');
      return false;
    } on http.ClientException catch (e) {
      print('DEBUG [SignupViewModel]: HTTP ClientException caught: $e');
      _setErrorMessage('Network error. Please try again.');
      _setLoading(false);
      print('DEBUG [SignupViewModel]: Returning false (client exception)');
      return false;
    } on FormatException catch (e) {
      print('DEBUG [SignupViewModel]: FormatException caught: $e');
      _setErrorMessage('Invalid response from server.');
      _setLoading(false);
      print('DEBUG [SignupViewModel]: Returning false (format exception)');
      return false;
    } catch (e, stackTrace) {
      print('DEBUG [SignupViewModel]: Unexpected exception caught: $e');
      print('DEBUG [SignupViewModel]: Stack trace: $stackTrace');
      print('DEBUG [SignupViewModel]: Exception type: ${e.runtimeType}');
      
      String errorMsg = 'An error occurred during registration';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Request timeout. Please check your internet connection.';
        print('DEBUG [SignupViewModel]: Timeout detected in error message');
      } else if (e.toString().contains('Failed host lookup')) {
        errorMsg = 'No internet connection. Please check your network.';
        print('DEBUG [SignupViewModel]: DNS lookup failure detected');
      } else if (e.toString().contains('HandshakeException') || 
                 e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        errorMsg = 'SSL certificate error. Please try again later.';
        print('DEBUG [SignupViewModel]: SSL certificate error detected');
      }
      
      print('DEBUG [SignupViewModel]: Final error message: "$errorMsg"');
      _setErrorMessage(errorMsg);
      _setLoading(false);
      print('DEBUG [SignupViewModel]: Returning false (unexpected exception)');
      return false;
    } finally {
      // Always close the client to free up resources
      client.close();
      print('DEBUG [SignupViewModel]: HTTP client closed');
    }
  }

  /// Test API connectivity with custom SSL handling
  Future<bool> testConnection() async {
    print('DEBUG [SignupViewModel]: Testing API connectivity...');
    final client = _createHttpClient();
    
    try {
      final url = Uri.parse('$_baseUrl/health'); // Assuming there's a health check endpoint
      print('DEBUG [SignupViewModel]: Testing connection to: $url');
      
      final response = await client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter App v1.0',
        },
      ).timeout(
        const Duration(seconds: 10),
      );
      
      print('DEBUG [SignupViewModel]: Connection test response: ${response.statusCode}');
      final isConnected = response.statusCode == 200;
      print('DEBUG [SignupViewModel]: Connection test result: $isConnected');
      return isConnected;
    } catch (e) {
      print('DEBUG [SignupViewModel]: Connection test failed: $e');
      return false;
    } finally {
      client.close();
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    print('DEBUG [SignupViewModel]: Email validation for "$email": $isValid');
    return isValid;
  }

  /// Validate phone number format
  bool isValidPhone(String phone) {
    // Assuming 10-digit Indian phone number
    final isValid = RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
    print('DEBUG [SignupViewModel]: Phone validation for "$phone": $isValid (Indian format [6-9]xxxxxxxxx)');
    return isValid;
  }

  /// Validate password strength
  Map<String, bool> validatePassword(String password) {
    final validation = {
      'minLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumbers': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
    print('DEBUG [SignupViewModel]: Password validation result: $validation');
    return validation;
  }

  /// Check if passwords match
  bool doPasswordsMatch(String password, String confirmPassword) {
    final match = password == confirmPassword;
    print('DEBUG [SignupViewModel]: Password match check: $match');
    return match;
  }

  /// Clear error message
  void clearError() {
    print('DEBUG [SignupViewModel]: Clearing error message');
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    print('DEBUG [SignupViewModel]: Clearing success message');
    _successMessage = null;
    notifyListeners();
  }

  /// Clear all messages
  void _clearMessages() {
    print('DEBUG [SignupViewModel]: Clearing all messages');
    _errorMessage = null;
    _successMessage = null;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    print('DEBUG [SignupViewModel]: Setting loading state to: $loading');
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setErrorMessage(String message) {
    print('DEBUG [SignupViewModel]: Setting error message: "$message"');
    _errorMessage = message;
    notifyListeners();
  }

  /// Set success message
  void _setSuccessMessage(String message) {
    print('DEBUG [SignupViewModel]: Setting success message: "$message"');
    _successMessage = message;
    notifyListeners();
  }

  /// Reset all states
  void reset() {
    print('DEBUG [SignupViewModel]: Resetting all states');
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    print('DEBUG [SignupViewModel]: Disposing SignupViewModel');
    // Clean up any resources if needed
    super.dispose();
  }
}