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
          'هل يمكن للجمال أن يكون ذكياً؟ ديوماكس وُجد ليجيب. كل بكسل هنا مدروس، كل حركة لها معنى، وكل أداة وُضعت لتكون امتداداً طبيعياً ليدك وتفكيرك. تجربة غامضة بسلاستها، ومدهشة بذكائها. أنت لا تستخدم تطبيقاً.. أنت تعيش تجربة ديوماكس.',
      icon: Icons.rocket_launch,
      isWelcomePage: true,
    ),
    OnboardingPageData(
      title: 'سهولة الاستخدام',
      description:
          'إبداع في البساطة وقوة في الأداء. واجهة ذكية صُممت خصيصاً لتتناغم مع حركتك، حيث كل عنصر ومسافة ولون خضع لدراسة دقيقة ليمنحك تجربة استخدام فائقة السلاسة والسرعة',
      icon: Icons.auto_awesome,
    ),
    OnboardingPageData(
      title: 'الأمان والاحتياط',
      description:
          'خصوصية مطلقة وأمان متكامل. تُخزن بياناتك مشفرة محلياً على جهازك لضمان السرية، مع منظومة نسخ احتياطي ذكية (سحابية ومحلية) تمنحك الطمأنينة الكاملة والقدرة على استعادة معلوماتك في أي وقت',
      icon: Icons.shield_outlined,
    ),
    OnboardingPageData(
      title: 'مجاني بالكامل',
      description:
          'قل وداعاً للاشتراكات الشهرية والإعلانات المزعجة التي تسرق تركيزك. استمتع بتجربة مجانية 100%، نظيفة، وكاملة المزايا. نعم، إنه ديوماكس يا صديقي!',
      icon: Icons.card_giftcard,
    ),
    OnboardingPageData(
      title: 'التكامل والمرونة',
      description:
          'صُمم ليدهشك! يتحدث لغتك، يدعم عملتك، وينبهك لكل صغيرة وكبيرة بذكاء فائق. تجربة متكاملة ستجعلك تتساءل: كيف كانت حياتي المالية قبله؟',
      icon: Icons.bolt,
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
          // الخلفية
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _currentPage == 0
                ? Container(
                    key: const ValueKey('welcome_bg'),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F0C29), // بنفسجي غامق جداً
                          Color(0xFF302B63), // نيلي غامق
                          Color(0xFF24243E), // كحلي غامق
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // تأثيرات ضبابية لخلق الغموض
                        Positioned(
                          top: -100,
                          right: -100,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 80,
                              sigmaY: 80,
                            ),
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFF00D4FF,
                                ).withOpacity(0.15),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          left: -50,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 80,
                              sigmaY: 80,
                            ),
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFFFF00CC,
                                ).withOpacity(0.15), // ماجنتا
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Image.asset(
                    'assets/images/onboarding_bg.jpg',
                    key: const ValueKey('standard_bg'),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
            child: Text(
              'تخطي',
              style: TextStyle(
                color: Colors.white.withOpacity(_currentPage == 0 ? 0.7 : 1.0),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // أيقونة التطبيق (تختفي في الصفحة الأولى لأنها موجودة في الوسط)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _currentPage == 0 ? 0.0 : 1.0,
            child: Container(
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
                          colors: [
                            Colors.orange.shade400,
                            Colors.pink.shade400,
                          ],
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
          ),
        ],
      ),
    );
  }

  /// بناء صفحة الترحيب الرئيسية بتصميم مبتكر وغامض
  Widget _buildWelcomePage(OnboardingPageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // شعار التطبيق بتصميم متوهج ومثير
          Stack(
            alignment: Alignment.center,
            children: [
              // هالة خلفية متوهجة
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.4),
                      const Color(0xFFFF00CC).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // الحاوية الرئيسية للشعار
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          // النصوص بتصميم مبتكر
          Column(
            children: [
              Text(
                'مرحباً بك في عالم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF00D4FF), // تركواز مشع
                  letterSpacing: 4,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              // اسم التطبيق بتدرج لوني مبتكر
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF00D4FF), // تركواز
                    Color(0xFFBC13FE), // بنفسجي كهربائي
                    Color(0xFFFF00CC), // ماجنتا
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'ديوماكس',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                    fontFamily: 'Cairo',
                    letterSpacing: -2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // الوصف
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.8),
                height: 1.8,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w300,
                // ظلال ناعمة للنص لتحسين القراءة
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
