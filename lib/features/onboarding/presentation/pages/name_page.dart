import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/theme/onboarding_theme.dart';
import '../setup/onboarding_provider.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // تحميل الاسم المحفوظ بعد بناء Widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedName();
    });
  }

  /// تحميل الاسم المحفوظ من Provider إذا كان موجوداً
  void _loadSavedName() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    if (provider.userName.isNotEmpty && _controller.text.isEmpty) {
      _controller.text = provider.userName;
      setState(() => _hasText = true);
    }
  }

  void _onTextChanged() {
    final name = _controller.text.trim();
    final hasText = name.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.updateUserName(name);
    provider.setNameReady(hasText);
  }

  void _goToNextPage() {
    if (_hasText) {
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      provider.pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // أيقونة التطبيق في الأعلى
                _buildAppIcon(),

                const SizedBox(height: 40),

                // البطاقة الرئيسية
                _buildMainCard(),

                const Spacer(flex: 1),

                // زر التالي
                _buildNextButton(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: OnboardingTheme.primary.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/icon/app_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    OnboardingTheme.primary,
                    OnboardingTheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _hasText
              ? OnboardingTheme.primary.withOpacity(0.4)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // أيقونة المستخدم
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _hasText
                  ? OnboardingTheme.primary.withOpacity(0.15)
                  : Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: _hasText
                    ? OnboardingTheme.primary.withOpacity(0.5)
                    : Colors.white.withOpacity(0.15),
                width: 2,
              ),
            ),
            child: Icon(
              _hasText ? Icons.person : Icons.person_outline_rounded,
              size: 32,
              color: _hasText
                  ? OnboardingTheme.primary
                  : Colors.white.withOpacity(0.5),
            ),
          ),

          const SizedBox(height: 28),

          // العنوان الرئيسي
          const Text(
            'ما اسمك؟',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          // الوصف الفرعي
          Text(
            'سيظهر في إشعارات التذكير والتقارير',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              fontFamily: 'Cairo',
            ),
          ),

          const SizedBox(height: 32),

          // حقل الإدخال المحسّن
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(_focusNode.hasFocus ? 0.12 : 0.08),
                  Colors.white.withOpacity(_focusNode.hasFocus ? 0.08 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _focusNode.hasFocus || _hasText
                    ? OnboardingTheme.primary.withOpacity(0.6)
                    : Colors.white.withOpacity(0.12),
                width: _focusNode.hasFocus ? 2 : 1.5,
              ),
              boxShadow: _focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: OnboardingTheme.primary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: 'Cairo',
              ),
              cursorColor: OnboardingTheme.primary,
              cursorWidth: 2.5,
              cursorRadius: const Radius.circular(2),
              decoration: InputDecoration(
                hintText: 'اكتب اسمك أو اسم متجرك',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
              ),
              onSubmitted: (_) => _goToNextPage(),
            ),
          ),

          // رسالة الترحيب
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _hasText
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: OnboardingTheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: OnboardingTheme.primary,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'أهلاً ${_controller.text.trim()} 👋',
                          style: const TextStyle(
                            color: OnboardingTheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return AnimatedScale(
      scale: _hasText ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 200),
      child: AnimatedOpacity(
        opacity: _hasText ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _hasText ? _goToNextPage : null,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Ink(
              decoration: BoxDecoration(
                gradient: _hasText
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [OnboardingTheme.primary, Color(0xFF3DB8B0)],
                      )
                    : null,
                color: _hasText ? null : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                boxShadow: _hasText
                    ? [
                        BoxShadow(
                          color: OnboardingTheme.primary.withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFF3DB8B0).withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _hasText
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        fontFamily: 'Cairo',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _hasText
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _hasText
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
