import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/unified_theme.dart';

class SlidingBannerWidget extends StatefulWidget {
  final List<BannerItem> banners;
  final Duration autoSlideInterval;
  final double height;

  const SlidingBannerWidget({
    super.key,
    required this.banners,
    this.autoSlideInterval = const Duration(seconds: 5),
    this.height = 150,
  });

  @override
  State<SlidingBannerWidget> createState() => _SlidingBannerWidgetState();
}

class _SlidingBannerWidgetState extends State<SlidingBannerWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Timer _autoSlideTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _startAutoSlide();
    _fadeController.forward();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(widget.autoSlideInterval, (timer) {
      if (mounted && widget.banners.isNotEmpty) {
        _nextSlide();
      }
    });
  }

  void _nextSlide() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.banners.length;
    });
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToSlide(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _autoSlideTimer.cancel();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _autoSlideTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: Stack(
        children: [
          // Banner Pages
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.banners.length,
              itemBuilder: (context, index) {
                return _buildBannerCard(widget.banners[index]);
              },
            ),
          ),

          // Dots Indicator
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BannerItem banner) {
    return Container(
      decoration: BoxDecoration(
        gradient: banner.backgroundImage == null ? banner.gradient : null,
        image: banner.backgroundImage != null ? DecorationImage(
          image: AssetImage(banner.backgroundImage!),
          fit: BoxFit.cover,
        ) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(banner.backgroundImage != null ? 0.5 : 0.3),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeController,
                  child: Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _fadeController,
                  child: Text(
                    banner.subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                if (banner.buttonText != null)
                  FadeTransition(
                    opacity: _fadeController,
                    child: GestureDetector(
                      onTap: banner.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          banner.buttonText!,
                          style: TextStyle(
                            color: banner.gradient.colors.first,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Floating icon (optional)
          if (banner.icon != null)
            Positioned(
              right: 20,
              top: 20,
              child: Icon(
                banner.icon,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return GestureDetector(
      onTap: () => _goToSlide(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _currentIndex == index ? 12 : 10,
        height: _currentIndex == index ? 12 : 10,
        decoration: BoxDecoration(
          color: _currentIndex == index
              ? Colors.white
              : Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class BannerItem {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final String? backgroundImage;
  final IconData? icon;

  BannerItem({
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onTap,
    required this.gradient,
    this.backgroundImage,
    this.icon,
  });
}

// Predefined banner items
class DefaultBanners {
  static List<BannerItem> get vetPathshalaBanners => [
    BannerItem(
      title: 'Summer Sale',
      subtitle: 'Get 50% off on all ebooks this week',
      buttonText: 'Shop Now',
      gradient: UnifiedTheme.primaryGradient,
      backgroundImage: 'assets/images/courses.png',
      icon: Icons.local_offer,
      onTap: () {
        // Handle shop now tap
      },
    ),
    BannerItem(
      title: 'New Courses',
      subtitle: 'Explore our latest veterinary courses',
      buttonText: 'Explore',
      gradient: const LinearGradient(
        colors: [UnifiedTheme.secondary, Color(0xFF1E3A8A)],
      ),
      backgroundImage: 'assets/images/lecture.png',
      icon: Icons.book,
      onTap: () {
        // Handle explore tap
      },
    ),
    BannerItem(
      title: 'Refer & Earn',
      subtitle: 'Get ₹50 for every successful referral',
      buttonText: 'Invite Now',
      gradient: UnifiedTheme.goldGradient,
      backgroundImage: 'assets/images/q_bank.png',
      icon: Icons.card_giftcard,
      onTap: () {
        // Handle invite tap
      },
    ),
  ];
}