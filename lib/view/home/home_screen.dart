import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../../core/constants/theme.dart';

class HomeScreen extends StatefulWidget {
  final String? userEmail;
  
  const HomeScreen({super.key, this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables
  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  Map<String, dynamic>? homeData;
  bool isLoading = true;
  late Timer _bannerTimer;

  // Asset image paths
  final List<String> _topSellingImages = [
    'assets/images/top_selling/macbook1.png',
    'assets/images/top_selling/macbook2.png',
    'assets/images/top_selling/macbook3.png',
  ];

  final List<String> _bestOffersImages = [
    'assets/images/top_selling/macbook1.png',
    'assets/images/top_selling/macbook4.png',
    'assets/images/top_selling/macbook5.png',
    'assets/images/top_selling/macbook6.png',
    'assets/images/top_selling/macbook3.png',
    'assets/images/top_selling/macbook7.png',
    'assets/images/top_selling/macbook2.png',
  ];

  // Banner data
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Onam Special',
      'subtitle': 'Exclusive Offer',
      'description': 'Celebrate this Onam with unbeatable deals,Limited time only!',
      'image': 'assets/images/carousel/mahabali.png',
      'giftImage': 'assets/images/carousel/gift.png',
      'bgColor1': Color(0xFFFDD835),
      'bgColor2': Color(0xFFFFEB3B),
    },
    {
      'title': 'Special Gift',
      'subtitle': 'Limited Time Offer',
      'description': 'Get amazing gifts with every purchase\nabove Rs. 5000',
      'image': 'assets/images/carousel/gift.png',
      'bgColor1': Color(0xFFFDD835),
      'bgColor2': Color(0xFFFFEB3B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _bannerTimer.cancel();
    super.dispose();
  }

  // Initialization methods
  void _initialize() {
    _configureHttpClient();
    _fetchHomeData();
    _startBannerTimer();
  }

  void _configureHttpClient() {
    HttpOverrides.global = _MyHttpOverrides();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        });
      }
    });
  }

  // Helper method to get display name from email
  String _getDisplayName(String? email) {
    if (email == null || email.isEmpty) {
      return 'User';
    }
    
    // Extract name part before @ symbol
    String namePart = email.split('@')[0];
    
    // Capitalize first letter and replace dots/underscores with spaces
    String displayName = namePart
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
    
    return displayName.isNotEmpty ? displayName : 'User';
  }

  // API methods
  Future<void> _fetchHomeData() async {
    try {
      final response = await _makeApiCall();
      _handleApiResponse(response);
    } catch (e) {
      _handleApiError(e);
    }
  }

  Future<http.Response> _makeApiCall() async {
    final client = http.Client();
    return await client.get(
      Uri.parse('https://app.ecominnerix.com/api/v1/home'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Flutter App/1.0',
      },
    );
  }

  void _handleApiResponse(http.Response response) {
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        homeData = data;
        isLoading = false;
      });
      _logApiData(data);
    } else {
      setState(() => isLoading = false);
      print('Failed to load data: ${response.statusCode}');
    }
  }

  void _handleApiError(dynamic error) {
    setState(() => isLoading = false);
    print('Error fetching data: $error');
    
    if (mounted) {
      _showErrorSnackBar(error.toString());
    }
  }

  void _logApiData(Map<String, dynamic> data) {
    print('Categories: ${data['categories']}');
    print('Top Selling: ${data['top_selling_items']}');
    print('Best Offers: ${data['best_offers']}');
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load data: $error'),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _retryDataFetch() {
    setState(() {
      isLoading = true;
      homeData = null;
    });
    _fetchHomeData();
  }

  // Build methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fillColor,
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }
    
    if (homeData == null) {
      return _buildErrorWidget();
    }
    
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildBannerSection(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildSectionWithData('categories', _buildCategoriesSection),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildSectionWithData('top_selling_items', _buildTopSellingSection),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildSectionWithData('best_offers', _buildBestOffersSection),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithData(String key, Widget Function() builder) {
    if (_hasValidData(key)) {
      return builder();
    }
    return _buildNoDataWidget('No $key data');
  }

  bool _hasValidData(String key) {
    return homeData?[key] != null && homeData![key]['items'] != null;
  }

  Widget _buildNoDataWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Text(
        message,
        style: const TextStyle(color: Colors.orange),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor.withOpacity(0.6),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            const Text(
              'Failed to load data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            const Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton(
              onPressed: _retryDataFetch,
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingXXLarge,
                    vertical: AppTheme.paddingSmall + 4,
                  ),
                ),
              ),
              child: Text('Retry', style: AppTheme.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final displayName = _getDisplayName(widget.userEmail);
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $displayName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const Text(
                "Let's start shopping",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        _buildHeaderIcon(Icons.favorite_border),
        const SizedBox(width: AppTheme.paddingSmall + 4),
        _buildHeaderIcon(Icons.notifications_outlined),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9C4),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppTheme.primaryColor,
        size: AppTheme.iconSize,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: AppTheme.hintText,
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    final banner = _banners[_currentBannerIndex];
    
    return Column(
      children: [
        _buildBanner(banner),
        const SizedBox(height: AppTheme.paddingSmall + 4),
        _buildBannerIndicators(),
      ],
    );
  }

  Widget _buildBanner(Map<String, dynamic> banner) {
    final isGiftBanner = _currentBannerIndex == 1;
    
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [banner['bgColor1'], banner['bgColor2']],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius + 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium + 4),
        child: Row(
          children: [
            _buildBannerImage(banner, isGiftBanner),
            _buildBannerText(banner),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage(Map<String, dynamic> banner, bool isGiftBanner) {
    if (isGiftBanner) {
      return Expanded(
        flex: 2,
        child: Center(
          child: _buildBannerImageWidget(
            banner['image'],
            120,
            120,
            Icons.card_giftcard,
            AppTheme.successColor.withOpacity(0.6),
          ),
        ),
      );
    }

    return Expanded(
      flex: 2,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: _buildBannerImageWidget(
              banner['image'],
              120,
              120,
              Icons.person,
              Colors.orange[300]!,
            ),
          ),
          Positioned(
            left: 50,
            bottom: 0,
            child: _buildBannerImageWidget(
              banner['giftImage'],
              80,
              80,
              Icons.card_giftcard,
              Colors.red[300]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerImageWidget(
    String imagePath,
    double width,
    double height,
    IconData fallbackIcon,
    Color fallbackColor,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: fallbackColor,
              borderRadius: BorderRadius.circular(AppTheme.paddingSmall),
            ),
            child: Icon(
              fallbackIcon,
              color: AppTheme.backgroundColor,
              size: width * 0.4,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerText(Map<String, dynamic> banner) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            banner['title'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.right,
          ),
          Text(
            banner['subtitle'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            banner['description'],
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentBannerIndex == index 
                ? AppTheme.primaryColor 
                : AppTheme.disabledColor,
          ),
        );
      }),
    );
  }

  Widget _buildCategoriesSection() {
    final categoriesData = homeData!['categories'];
    final categories = categoriesData['items'] as List;
    
    return _buildSection(
      title: categoriesData['title'] ?? 'Categories',
      height: 90,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryItem(category['category_name'] ?? 'Category');
      },
    );
  }

  Widget _buildTopSellingSection() {
    final topSellingData = homeData!['top_selling_items'];
    final topSellingItems = topSellingData['items'] as List;
    
    return _buildSection(
      title: topSellingData['title'] ?? 'Top Selling',
      height: 220,
      itemCount: topSellingItems.length,
      itemBuilder: (context, index) {
        final product = topSellingItems[index];
        final localImage = index < _topSellingImages.length ? _topSellingImages[index] : null;
        
        return _buildProductCard(
          title: product['name'] ?? 'Product',
          price: 'Rs. ${product['price']}.00',
          rating: '4.6',
          reviews: '28 Reviews',
          imageUrl: product['thumbnail_image'],
          localAssetImage: localImage,
        );
      },
    );
  }

  Widget _buildBestOffersSection() {
    final bestOffersData = homeData!['best_offers'];
    final bestOffers = bestOffersData['items'] as List;
    
    return _buildSection(
      title: bestOffersData['title'] ?? 'Best offers',
      height: 220,
      itemCount: bestOffers.length,
      itemBuilder: (context, index) {
        final product = bestOffers[index];
        final localImage = index < _bestOffersImages.length ? _bestOffersImages[index] : null;
        
        return _buildProductCard(
          title: product['name'] ?? 'Product',
          price: 'Rs. ${product['price']}.00',
          rating: '4.9',
          reviews: '88 Reviews',
          imageUrl: product['thumbnail_image'],
          localAssetImage: localImage,
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required double height,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Column(
      children: [
        _buildSectionHeader(title),
        const SizedBox(height: AppTheme.paddingMedium),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            title.contains('Categories') ? 'See All' : 'View All',
            style: const TextStyle(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String categoryName) {
    return Container(
      margin: const EdgeInsets.only(right: AppTheme.paddingMedium),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 210, 209, 209),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: _getCategoryWidget(categoryName),
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          SizedBox(
            width: 50,
            child: Text(
              categoryName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryWidget(String categoryName) {
    final imagePath = _getCategoryImagePath(categoryName);
    
    if (imagePath != null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Image.asset(
          imagePath,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildCategoryIcon(categoryName);
          },
        ),
      );
    }
    
    return _buildCategoryIcon(categoryName);
  }

  Widget _buildCategoryIcon(String categoryName) {
    return Center(
      child: Icon(
        _getCategoryIconData(categoryName),
        color: Colors.black54,
        size: AppTheme.paddingLarge,
      ),
    );
  }

  String? _getCategoryImagePath(String categoryName) {
    final categoryMap = {
      'mobile': 'assets/images/category/mobile.png',
      'tv': 'assets/images/category/tv.png',
      'fridge': 'assets/images/category/fridge.png',
      'shoes': 'assets/images/category/shoes.png',
      'tab': 'assets/images/category/tab.png',
      'laptop': 'assets/images/category/laptop.png',
      'laptops': 'assets/images/category/laptop.png',
      'desktop': 'assets/images/category/desktop.png',
      'desktops': 'assets/images/category/desktop.png',
      'ac': 'assets/images/category/ac.png',
      'gift': 'assets/images/category/gift.png',
      'gifts': 'assets/images/category/gift.png',
      'remote': 'assets/images/category/remote.png',
      'remotes': 'assets/images/category/remote.png',
    };
    
    return categoryMap[categoryName.toLowerCase()];
  }

  IconData _getCategoryIconData(String categoryName) {
    final iconMap = {
      'mobile': Icons.phone_android,
      'tv': Icons.tv,
      'fridge': Icons.kitchen,
      'shoes': Icons.run_circle,
      'tab': Icons.tablet,
      'laptop': Icons.laptop,
      'laptops': Icons.laptop,
      'desktop': Icons.computer,
      'desktops': Icons.computer,
      'ac': Icons.ac_unit,
      'gift': Icons.card_giftcard,
      'gifts': Icons.card_giftcard,
      'remote': Icons.settings_remote,
      'remotes': Icons.settings_remote,
    };
    
    return iconMap[categoryName.toLowerCase()] ?? Icons.category;
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String rating,
    required String reviews,
    String? imageUrl,
    String? localAssetImage,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImageContainer(localAssetImage, imageUrl),
          _buildProductDetails(title, price, rating, reviews),
        ],
      ),
    );
  }

  Widget _buildProductImageContainer(String? localAssetImage, String? imageUrl) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: _buildProductImage(localAssetImage, imageUrl),
      ),
    );
  }

  Widget _buildProductDetails(String title, String price, String rating, String reviews) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            _buildRatingRow(rating, reviews),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String rating, String reviews) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 12,
          color: Colors.amber[600],
        ),
        const SizedBox(width: 2),
        Text(
          rating,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            reviews,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String? localAssetImage, String? networkImageUrl) {
    if (localAssetImage != null) {
      return Image.asset(
        localAssetImage,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildNetworkOrPlaceholderImage(networkImageUrl);
        },
      );
    }
    
    return _buildNetworkOrPlaceholderImage(networkImageUrl);
  }

  Widget _buildNetworkOrPlaceholderImage(String? networkImageUrl) {
    if (networkImageUrl != null) {
      return Image.network(
        networkImageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
    
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return const Center(
      child: Icon(
        Icons.image,
        size: 32,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedItemColor: const Color(0xFFD4A574),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Offers'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

// Custom HttpOverrides class for development
class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) {
        print('Certificate verification failed for $host:$port');
        return true; // Development only - accept all certificates
      };
  }
}