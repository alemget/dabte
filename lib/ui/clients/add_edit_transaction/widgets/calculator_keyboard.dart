import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';

/// بيانات العملة للعرض
class CurrencyDisplayData {
  final String code;
  final String name;
  final String flag;

  const CurrencyDisplayData({
    required this.code,
    required this.name,
    required this.flag,
  });
}

/// آلة حاسبة احترافية مدمجة لإدخال المبالغ
/// Professional integrated calculator with thumb-friendly design
class CalculatorKeyboard extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onValueChanged;
  final VoidCallback? onDone;
  final List<CurrencyDisplayData> currencyData;
  final String selectedCurrencyCode;
  final ValueChanged<String>? onCurrencyChanged;
  final Color activeColor;
  final bool showDoneButton;
  final bool compactMode;

  const CalculatorKeyboard({
    super.key,
    this.initialValue = '',
    required this.onValueChanged,
    this.onDone,
    this.currencyData = const [],
    this.selectedCurrencyCode = '',
    this.onCurrencyChanged,
    this.activeColor = const Color(0xFF059669),
    this.showDoneButton = true,
    this.compactMode = false,
  });

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard>
    with SingleTickerProviderStateMixin {
  String _display = '0';
  double? _firstOperand;
  String? _pendingOperator;
  bool _shouldResetDisplay = false;
  bool _hasCalculated = false;

  late AnimationController _enterController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue.isNotEmpty) {
      _display = widget.initialValue;
      _firstOperand = double.tryParse(widget.initialValue);
    }

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
        );
    _fadeAnimation = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CalculatorKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _display &&
        widget.initialValue.isNotEmpty &&
        !_hasCalculated) {
      setState(() {
        _display = widget.initialValue;
        if (_pendingOperator == null) {
          _firstOperand = double.tryParse(widget.initialValue);
        }
      });
    }
  }

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _hasCalculated = false;
      if (_display == '0' || _shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display.length < 12) {
          _display += digit;
        }
      }
    });
    _notifyChange();
  }

  void _onDecimalPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperatorPressed(String operator) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_pendingOperator != null && !_shouldResetDisplay) {
        _calculateResult();
      }
      if (!_hasCalculated) {
        _firstOperand = double.tryParse(_display);
      }
      _pendingOperator = operator;
      _shouldResetDisplay = true;
      _hasCalculated = true;
    });
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }

  void _calculateResult() {
    if (_firstOperand == null || _pendingOperator == null) return;

    final currentValue = double.tryParse(_display) ?? 0;
    double newResult;

    switch (_pendingOperator) {
      case '+':
        newResult = _firstOperand! + currentValue;
        break;
      case '-':
        newResult = _firstOperand! - currentValue;
        break;
      case '×':
        newResult = _firstOperand! * currentValue;
        break;
      case '÷':
        if (currentValue == 0) {
          newResult = 0;
        } else {
          newResult = _firstOperand! / currentValue;
        }
        break;
      case '%':
        newResult = _firstOperand! * (currentValue / 100);
        break;
      default:
        return;
    }

    setState(() {
      _display = _formatNumber(newResult);
      _firstOperand = newResult;
      _pendingOperator = null;
      _shouldResetDisplay = true;
      _hasCalculated = true;
    });
    _notifyChange();
  }

  void _onEqualsPressed() {
    HapticFeedback.mediumImpact();
    _calculateResult();
  }

  void _onClearPressed() {
    HapticFeedback.mediumImpact();
    setState(() {
      _display = '0';
      _firstOperand = null;
      _pendingOperator = null;
      _shouldResetDisplay = false;
      _hasCalculated = false;
    });
    _notifyChange();
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
    _notifyChange();
  }

  void _notifyChange() {
    final value = _display == '0' ? '' : _display;
    widget.onValueChanged(value);
  }

  void _onDonePressed() {
    HapticFeedback.mediumImpact();
    if (_pendingOperator != null) {
      _calculateResult();
    }
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Responsive sizing
    final buttonHeight = widget.compactMode ? 52.0 : 58.0;
    final buttonSpacing = 10.0;
    final horizontalPadding = 16.0;

    // ألوان محسنة نفسياً
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final digitColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    // ألوان العمليات
    final operatorColor = const Color(0xFF6366F1);
    final operatorBgColor = operatorColor.withOpacity(isDark ? 0.15 : 0.1);

    // ألوان خاصة
    final clearColor = const Color(0xFFF43F5E);
    final clearBgColor = clearColor.withOpacity(isDark ? 0.15 : 0.1);
    final equalsColor = const Color(0xFF3B82F6);
    final equalsBgColor = equalsColor.withOpacity(isDark ? 0.15 : 0.1);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 14),

                // Currency Selector with Flags
                if (widget.currencyData.isNotEmpty) ...[
                  _buildCurrencySelector(
                    isDark,
                    digitColor,
                    mutedColor,
                    surfaceColor,
                  ),
                  const SizedBox(height: 10),
                ],

                // Calculator Buttons
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    8,
                    horizontalPadding,
                    horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      // Row 1: C, ⌫, %, ÷
                      Row(
                        children: [
                          _CalcButton(
                            text: 'C',
                            backgroundColor: clearBgColor,
                            foregroundColor: clearColor,
                            height: buttonHeight,
                            onPressed: _onClearPressed,
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            icon: Icons.backspace_outlined,
                            backgroundColor: surfaceColor,
                            foregroundColor: mutedColor,
                            height: buttonHeight,
                            onPressed: _onBackspacePressed,
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '%',
                            backgroundColor: operatorBgColor,
                            foregroundColor: operatorColor,
                            height: buttonHeight,
                            onPressed: () => _onOperatorPressed('%'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '÷',
                            backgroundColor: operatorBgColor,
                            foregroundColor: operatorColor,
                            height: buttonHeight,
                            onPressed: () => _onOperatorPressed('÷'),
                          ),
                        ],
                      ),
                      SizedBox(height: buttonSpacing),

                      // Row 2: 7, 8, 9, ×
                      Row(
                        children: [
                          _CalcButton(
                            text: '7',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('7'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '8',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('8'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '9',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('9'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '×',
                            backgroundColor: operatorBgColor,
                            foregroundColor: operatorColor,
                            height: buttonHeight,
                            onPressed: () => _onOperatorPressed('×'),
                          ),
                        ],
                      ),
                      SizedBox(height: buttonSpacing),

                      // Row 3: 4, 5, 6, -
                      Row(
                        children: [
                          _CalcButton(
                            text: '4',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('4'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '5',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('5'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '6',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('6'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '-',
                            backgroundColor: operatorBgColor,
                            foregroundColor: operatorColor,
                            height: buttonHeight,
                            onPressed: () => _onOperatorPressed('-'),
                          ),
                        ],
                      ),
                      SizedBox(height: buttonSpacing),

                      // Row 4: 1, 2, 3, +
                      Row(
                        children: [
                          _CalcButton(
                            text: '1',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('1'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '2',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('2'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '3',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('3'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '+',
                            backgroundColor: operatorBgColor,
                            foregroundColor: operatorColor,
                            height: buttonHeight,
                            onPressed: () => _onOperatorPressed('+'),
                          ),
                        ],
                      ),
                      SizedBox(height: buttonSpacing),

                      // Row 5: ., 0, =, Done
                      Row(
                        children: [
                          _CalcButton(
                            text: '.',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: _onDecimalPressed,
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '0',
                            backgroundColor: surfaceColor,
                            foregroundColor: digitColor,
                            height: buttonHeight,
                            onPressed: () => _onDigitPressed('0'),
                          ),
                          SizedBox(width: buttonSpacing),
                          _CalcButton(
                            text: '=',
                            backgroundColor: equalsBgColor,
                            foregroundColor: equalsColor,
                            height: buttonHeight,
                            onPressed: _onEqualsPressed,
                          ),
                          SizedBox(width: buttonSpacing),
                          widget.showDoneButton
                              ? _CalcButton(
                                  text: l10n.confirm,
                                  backgroundColor: widget.activeColor,
                                  foregroundColor: Colors.white,
                                  height: buttonHeight,
                                  isBold: true,
                                  isAccent: true,
                                  onPressed: _onDonePressed,
                                )
                              : _CalcButton(
                                  text: '00',
                                  backgroundColor: surfaceColor,
                                  foregroundColor: digitColor,
                                  height: buttonHeight,
                                  onPressed: () {
                                    _onDigitPressed('0');
                                    _onDigitPressed('0');
                                  },
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color surfaceColor,
  ) {
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final selectedBgColor = widget.activeColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: widget.currencyData.map((currency) {
          final isSelected = currency.code == widget.selectedCurrencyCode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onCurrencyChanged?.call(currency.code);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: selectedBgColor.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // علم العملة
                    Text(currency.flag, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    // اسم العملة
                    Flexible(
                      child: Text(
                        currency.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// زر الآلة الحاسبة المحسن
class _CalcButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final bool isBold;
  final bool isAccent;
  final VoidCallback onPressed;

  const _CalcButton({
    this.text,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.height,
    this.isBold = false,
    this.isAccent = false,
    required this.onPressed,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isAccent
                      ? [
                          BoxShadow(
                            color: widget.backgroundColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : (isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]),
                  border: widget.isAccent
                      ? null
                      : Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04),
                          width: 1,
                        ),
                ),
                child: Center(
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          color: widget.foregroundColor,
                          size: 24,
                        )
                      : Text(
                          widget.text!,
                          style: TextStyle(
                            fontSize: widget.text!.length > 2 ? 14 : 24,
                            fontWeight: widget.isBold
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: widget.foregroundColor,
                            letterSpacing: widget.text!.length > 2 ? 0 : 0.5,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
