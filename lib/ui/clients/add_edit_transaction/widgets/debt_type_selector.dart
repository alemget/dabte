import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';

/// مربع حوار اختيار نوع الدين (له/عليه) - Bottom Sheet احترافي
/// Professional debt type selector using Bottom Sheet for thumb-friendly access
class DebtTypeSelectorDialog extends StatelessWidget {
  const DebtTypeSelectorDialog({super.key});

  // ألوان مدروسة نفسياً - Psychologically optimized colors
  static const _greenPrimary = Color(0xFF059669);
  static const _greenLight = Color(0xFF10B981);
  static const _redPrimary = Color(0xFFDC2626);
  static const _redLight = Color(0xFFEF4444);

  /// عرض Bottom Sheet لاختيار النوع
  static Future<bool?> show(BuildContext context) {
    HapticFeedback.lightImpact();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => const DebtTypeSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // ألوان محسنة للوضعين
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Directionality(
      textDirection: l10n.localeName.startsWith('ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب - Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: mutedColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // العنوان - Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Column(
                children: [
                  // أيقونة متحركة
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.newDebt,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.selectDebtType,
                    style: TextStyle(
                      fontSize: 15,
                      color: mutedColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // الخيارات - Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // خيار "عليّ" (أحمر) - On Me
                  Expanded(
                    child: _DebtTypeCard(
                      title: l10n.onMe,
                      subtitle: l10n.debtOnMe,
                      icon: Icons.arrow_downward_rounded,
                      primaryColor: _redPrimary,
                      secondaryColor: _redLight,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  // خيار "لي" (أخضر) - For Me
                  Expanded(
                    child: _DebtTypeCard(
                      title: l10n.forMe,
                      subtitle: l10n.debtForMe,
                      icon: Icons.arrow_upward_rounded,
                      primaryColor: _greenPrimary,
                      secondaryColor: _greenLight,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // زر الإلغاء - Cancel Button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.cancel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة نوع الدين المحسنة
class _DebtTypeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _DebtTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DebtTypeCard> createState() => _DebtTypeCardState();
}

class _DebtTypeCardState extends State<_DebtTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: 0.35,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.primaryColor, widget.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(
                      _glowAnimation.value,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة محسنة
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
