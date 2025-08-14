import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class LoginViewModel extends ChangeNotifier {
  final _baseUrl = "https://app.ecominnerix.com/api";
  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _user;
  
  // HTTP client with SSL bypass
  late http.Client _httpClient;

  LoginViewModel() {
    _initializeHttpClient();
  }

  void _initializeHttpClient() {
    // Create HttpClient with SSL bypass
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      debugPrint("⚠️ SSL Certificate bypassed for $host:$port");
      debugPrint("Certificate subject: ${cert.subject}");
      debugPrint("Certificate issuer: ${cert.issuer}");
      return true; // Accept all certificates
    };
    
    // Create IOClient with the custom HttpClient
    _httpClient = IOClient(httpClient);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get user => _user;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Debug helper method to print request details
  void _printRequestDetails(String method, Uri url, Map<String, String> headers, String? body) {
    debugPrint("=== API REQUEST DEBUG ===");
    debugPrint("Method: $method");
    debugPrint("URL: $url");
    debugPrint("Headers: $headers");
    if (body != null) {
      debugPrint("Request Body: $body");
    }
    debugPrint("========================");
  }

  // Debug helper method to print response details
  void _printResponseDetails(http.Response response) {
    debugPrint("=== API RESPONSE DEBUG ===");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Headers: ${response.headers}");
    debugPrint("Response Body: ${response.body}");
    debugPrint("==========================");
  }

  Future<bool> loginWithPassword(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse("$_baseUrl/login");
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final requestBody = json.encode({
        "email": email,
        "password": password,
      });

      // Print request details for debugging
      _printRequestDetails("POST", url, headers, requestBody);
      
      final response = await _httpClient.post(
        url,
        headers: headers,
        body: requestBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );

      // Print response details for debugging
      _printResponseDetails(response);

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          
          // Check if login was successful based on the API response structure
          if (responseData['status'] == true) {
            // Store tokens and user data
            _accessToken = responseData['access_token'];
            _refreshToken = responseData['refresh_token'];
            _user = responseData['user'];
            
            debugPrint("✅ Login successful");
            debugPrint("Access Token: $_accessToken");
            debugPrint("User: ${_user?['name']} (${_user?['email']})");
            
            return true;
          } else {
            debugPrint("❌ Login failed: ${responseData['message']}");
            _setError(responseData['message'] ?? 'Login failed');
            return false;
          }
        } catch (e) {
          debugPrint("❌ Error parsing login response: $e");
          _setError("Invalid response format");
          return false;
        }
      } else {
        // Try to parse error message from response
        try {
          final responseData = json.decode(response.body);
          debugPrint("❌ Login failed with error: ${responseData['message']}");
          _setError(responseData['message'] ?? 'Login failed');
        } catch (e) {
          debugPrint("❌ Login failed with status: ${response.statusCode}");
          _setError("Login failed with status: ${response.statusCode}");
        }
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint("❌ Login timeout error: $e");
      _setError("Request timeout: Please check your internet connection");
      return false;
    } on SocketException catch (e) {
      debugPrint("❌ Login socket error: $e");
      _setError("Network error: Unable to connect to server");
      return false;
    } on HandshakeException catch (e) {
      debugPrint("❌ Login SSL error: $e");
      _setError("SSL connection error: Please check server certificate");
      return false;
    } catch (e) {
      debugPrint("❌ Login network error: $e");
      _setError("Network error: Unable to connect to server");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestOtp(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse("$_baseUrl/request-otp");
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final requestBody = json.encode({
        "email": email,
      });

      // Print request details for debugging
      _printRequestDetails("POST", url, headers, requestBody);
      
      final response = await _httpClient.post(
        url,
        headers: headers,
        body: requestBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );

      // Print response details for debugging
      _printResponseDetails(response);

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          
          if (responseData['status'] == true) {
            debugPrint("✅ OTP request successful");
            return true;
          } else {
            debugPrint("❌ OTP request failed: ${responseData['message']}");
            _setError(responseData['message'] ?? 'OTP request failed');
            return false;
          }
        } catch (e) {
          // If response is not JSON, assume success for 200 status
          debugPrint("✅ OTP request successful (non-JSON response)");
          return true;
        }
      } else {
        try {
          final responseData = json.decode(response.body);
          debugPrint("❌ OTP request failed: ${responseData['message']}");
          _setError(responseData['message'] ?? 'OTP request failed');
        } catch (e) {
          debugPrint("❌ OTP request failed with status: ${response.statusCode}");
          _setError("OTP request failed with status: ${response.statusCode}");
        }
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint("❌ OTP request timeout error: $e");
      _setError("Request timeout: Please check your internet connection");
      return false;
    } on SocketException catch (e) {
      debugPrint("❌ OTP request socket error: $e");
      _setError("Network error: Unable to connect to server");
      return false;
    } on HandshakeException catch (e) {
      debugPrint("❌ OTP request SSL error: $e");
      _setError("SSL connection error: Please check server certificate");
      return false;
    } catch (e) {
      debugPrint("❌ OTP request network error: $e");
      _setError("Network error: Unable to connect to server");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse("$_baseUrl/verify-otp");
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final requestBody = json.encode({
        "email": email,
        "otp": otp,
      });

      // Print request details for debugging
      _printRequestDetails("POST", url, headers, requestBody);
      
      final response = await _httpClient.post(
        url,
        headers: headers,
        body: requestBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );

      // Print response details for debugging
      _printResponseDetails(response);

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          
          if (responseData['status'] == true) {
            // Store tokens and user data if available
            _accessToken = responseData['access_token'];
            _refreshToken = responseData['refresh_token'];
            _user = responseData['user'];
            
            debugPrint("✅ OTP verification successful");
            return true;
          } else {
            debugPrint("❌ OTP verification failed: ${responseData['message']}");
            _setError(responseData['message'] ?? 'OTP verification failed');
            return false;
          }
        } catch (e) {
          debugPrint("✅ OTP verification successful (non-JSON response)");
          return true;
        }
      } else {
        try {
          final responseData = json.decode(response.body);
          debugPrint("❌ OTP verification failed: ${responseData['message']}");
          _setError(responseData['message'] ?? 'OTP verification failed');
        } catch (e) {
          debugPrint("❌ OTP verification failed with status: ${response.statusCode}");
          _setError("OTP verification failed with status: ${response.statusCode}");
        }
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint("❌ OTP verification timeout error: $e");
      _setError("Request timeout: Please check your internet connection");
      return false;
    } on SocketException catch (e) {
      debugPrint("❌ OTP verification socket error: $e");
      _setError("Network error: Unable to connect to server");
      return false;
    } on HandshakeException catch (e) {
      debugPrint("❌ OTP verification SSL error: $e");
      _setError("SSL connection error: Please check server certificate");
      return false;
    } catch (e) {
      debugPrint("❌ OTP verification network error: $e");
      _setError("Network error: Unable to connect to server");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signupWithEmail(String name, String email, String password) async {
  _setLoading(true);
  _setError(null);

  try {
    final url = Uri.parse("$_baseUrl/register"); // or /signup depending on your API
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final requestBody = json.encode({
      "name": name,
      "email": email,
      "password": password,
      // Add any other required fields like password_confirmation if needed
      // "password_confirmation": password,
    });

    // Print request details for debugging
    _printRequestDetails("POST", url, headers, requestBody);
    
    final response = await _httpClient.post(
      url,
      headers: headers,
      body: requestBody,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Request timeout', const Duration(seconds: 30));
      },
    );

    // Print response details for debugging
    _printResponseDetails(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseData = json.decode(response.body);
        
        // Check if signup was successful based on the API response structure
        if (responseData['status'] == true) {
          // Optionally store tokens and user data if returned
          if (responseData.containsKey('access_token')) {
            _accessToken = responseData['access_token'];
            _refreshToken = responseData['refresh_token'];
            _user = responseData['user'];
          }
          
          debugPrint("✅ Signup successful");
          debugPrint("User: $name ($email)");
          
          return true;
        } else {
          debugPrint("❌ Signup failed: ${responseData['message']}");
          _setError(responseData['message'] ?? 'Signup failed');
          return false;
        }
      } catch (e) {
        // If response is not JSON, assume success for 200/201 status
        debugPrint("✅ Signup successful (non-JSON response)");
        return true;
      }
    } else {
      // Try to parse error message from response
      try {
        final responseData = json.decode(response.body);
        debugPrint("❌ Signup failed with error: ${responseData['message']}");
        _setError(responseData['message'] ?? 'Signup failed');
      } catch (e) {
        debugPrint("❌ Signup failed with status: ${response.statusCode}");
        _setError("Signup failed with status: ${response.statusCode}");
      }
      return false;
    }
  } on TimeoutException catch (e) {
    debugPrint("❌ Signup timeout error: $e");
    _setError("Request timeout: Please check your internet connection");
    return false;
  } on SocketException catch (e) {
    debugPrint("❌ Signup socket error: $e");
    _setError("Network error: Unable to connect to server");
    return false;
  } on HandshakeException catch (e) {
    debugPrint("❌ Signup SSL error: $e");
    _setError("SSL connection error: Please check server certificate");
    return false;
  } catch (e) {
    debugPrint("❌ Signup network error: $e");
    _setError("Network error: Unable to connect to server");
    return false;
  } finally {
    _setLoading(false);
  }
}

  void clearError() {
    _setError(null);
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _setError(null);
    notifyListeners();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}