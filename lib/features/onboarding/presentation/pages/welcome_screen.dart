import 'dart:ui';
import 'package:flutter/material.dart';

/// نموذج بيانات لكل صفحة ترحيبية
class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final bool isWelcomePage;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    this.isWelcomePage = false,
  });
}

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const WelcomeScreen({super.key, required this.onFinished});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// بيانات الصفحات (صفحة ترحيب + 4 مزايا)
  final List<OnboardingPageData> _pages = const [
    // صفحة الترحيب الرئيسية
    OnboardingPageData(
      title: 'مرحباً بك في\nديوماكس',
      description:
          'رفيقك الذكي لإدارة حساباتك بكل سهولة واحترافية.\n'
          'نظّم ديونك، تابع عملائك، واحصل على تقارير دقيقة.\n'
          'ابدأ رحلتك نحو التحكم المالي الكامل.',
      icon: Icons.rocket_launch,
      isWelcomePage: true,
    ),
    OnboardingPageData(
      title: 'سهولة\nالاستخدام',
      description: 'واجهة سهلة وبديهية تجعل تجربتك ممتعة وسلسة',
      icon: Icons.auto_awesome,
    ),
    OnboardingPageData(
      title: 'الأمانة',
      description: 'نحمي بياناتك بأعلى معايير الأمان والخصوصية',
      icon: Icons.shield_outlined,
    ),
    OnboardingPageData(
      title: 'التكامل\nوالحيوية',
      description: 'تجربة متكاملة وديناميكية لتلبية جميع احتياجاتك',
      icon: Icons.bolt,
    ),
    OnboardingPageData(
      title: 'مجاني\nوآمن',
      description: 'تطبيق مجاني بالكامل بدون أي رسوم خفية أو قيود',
      icon: Icons.card_giftcard,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية الملونة
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // المحتوى الرئيسي
          SafeArea(
            child: Column(
              children: [
                // شريط العلوي: زر تخطي وأيقونة التطبيق
                _buildTopBar(),

                // محتوى الصفحات
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      // الصفحة الأولى تكون صفحة الترحيب مع الشعار
                      if (page.isWelcomePage) {
                        return _buildWelcomePage(page);
                      }
                      return _buildPage(page);
                    },
                  ),
                ),

                // مؤشرات الصفحات والزر
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// شريط العلوي مع زر التخطي
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر تخطي
          TextButton(
            onPressed: widget.onFinished,
            child: const Text(
              'تخطي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // أيقونة التطبيق
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.pink.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء صفحة الترحيب الرئيسية مع الشعار
  Widget _buildWelcomePage(OnboardingPageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // شعار التطبيق الكبير
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.orange.shade400, Colors.pink.shade400],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 70,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),

          // الحاوية الشفافة (Glassmorphism) مع النص
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عنوان الترحيب بتدرج ذهبي
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFD700), // ذهبي
                          Color(0xFFFF8C00), // برتقالي
                          Color(0xFFFFD700), // ذهبي
                        ],
                      ).createShader(bounds),
                      child: Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // خط فاصل أنيق
                    Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // الوصف الملهم
                    Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.7,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء صفحة واحدة (للمزايا)
  Widget _buildPage(OnboardingPageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الحاوية الشفافة (Glassmorphism)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الأيقونة في دائرة
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(data.icon, size: 45, color: Colors.white),
                    ),
                    const SizedBox(height: 28),

                    // العنوان
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // الوصف
                    Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// القسم السفلي: مؤشرات الصفحات والزر
  Widget _buildBottomSection() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // مؤشرات الصفحات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // زر التالي / ابدأ الآن
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastPage
                    ? const Color(0xFFFF6B35) // برتقالي للزر الأخير
                    : Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: isLastPage ? 0 : 1,
                  ),
                ),
                elevation: isLastPage ? 8 : 0,
                shadowColor: isLastPage
                    ? const Color(0xFFFF6B35).withOpacity(0.4)
                    : Colors.transparent,
              ),
              child: Text(
                isLastPage ? 'ابدأ الآن' : 'التالي',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
