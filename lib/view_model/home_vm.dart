import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeViewModel extends ChangeNotifier {
  final _baseUrl = "https://app.ecominnerix.com/api";
  bool isLoading = false;

  List<dynamic> categories = [];
  List<dynamic> products = [];
  List<dynamic> bestOffers = [];

  Future<void> fetchHomeData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch home sections
      final homeUrl = Uri.parse("$_baseUrl/v1/home");
      final homeRes = await http.get(homeUrl);

      if (homeRes.statusCode == 200) {
        final data = jsonDecode(homeRes.body);
        categories = data['categories'] ?? [];
        bestOffers = data['offers'] ?? [];
      } else {
        debugPrint("Home fetch failed: ${homeRes.body}");
      }

      // Fetch products
      final productUrl = Uri.parse("$_baseUrl/products?shop_id=1&page_size=100&page=1");
      final productRes = await http.get(productUrl);

      if (productRes.statusCode == 200) {
        final data = jsonDecode(productRes.body);
        products = data['data'] ?? [];
      } else {
        debugPrint("Product fetch failed: ${productRes.body}");
      }
    } catch (e) {
      debugPrint("Error fetching home data: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
