import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';

/// آلة حاسبة احترافية مدمجة لإدخال المبالغ
/// Professional integrated calculator for amount entry
class CalculatorKeyboard extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onValueChanged;
  final VoidCallback? onDone;
  final List<String> currencies;
  final String selectedCurrency;
  final ValueChanged<String>? onCurrencyChanged;
  final Color activeColor;
  final bool showDoneButton;
  final bool compactMode;

  const CalculatorKeyboard({
    super.key,
    this.initialValue = '',
    required this.onValueChanged,
    this.onDone,
    this.currencies = const [],
    this.selectedCurrency = '',
    this.onCurrencyChanged,
    this.activeColor = const Color(0xFF10B981),
    this.showDoneButton = true,
    this.compactMode = false,
  });

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard> {
  String _display = '0';
  double? _firstOperand;
  String? _pendingOperator;
  bool _shouldResetDisplay = false;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue.isNotEmpty) {
      _display = widget.initialValue;
      _firstOperand = double.tryParse(widget.initialValue);
    }
  }

  @override
  void didUpdateWidget(CalculatorKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // فقط نقوم بالتحديث إذا كانت القيمة الجديدة مختلفة عن القيمة المعروضة حالياً
    // هذا يمنع حلقة التحديث اللانهائية ومشاكل تزامن الحالة
    // Only update if new value differs from current display to prevent echo loops
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _display &&
        widget.initialValue.isNotEmpty &&
        !_hasCalculated) {
      setState(() {
        _display = widget.initialValue;
        // لا نحدث المعامل الأول إذا كنا في منتصف عملية حسابية
        // Don't update firstOperand if we are in the middle of a calculation
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

      // استخدام القيمة الدقيقة المحفوظة إذا كانت نتيجة عملية سابقة
      // لتجنب مشاكل دقة الأرقام العشرية عند تحويل النص
      // Use preserved precise value if it's a result of previous calculation
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
      final resultPart = _formatNumber(newResult);

      _display = resultPart;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonHeight = widget.compactMode ? 50.0 : 54.0;
    final buttonSpacing = screenWidth < 360 ? 6.0 : 8.0;
    final padding = screenWidth < 360 ? 10.0 : 12.0;

    // Colors
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8FAFC);
    final buttonColor = isDark ? const Color(0xFF252540) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final operatorColor = const Color(0xFF8B5CF6);
    final operatorBgColor = operatorColor.withOpacity(isDark ? 0.2 : 0.12);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
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
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: mutedColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            // Currency Tabs
            if (widget.currencies.isNotEmpty) ...[
              _buildCurrencyTabs(isDark, textColor, mutedColor),
              const SizedBox(height: 8),
            ],

            // Calculator Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 4, padding, padding),
              child: Column(
                children: [
                  // Row 1: C, ⌫, %, ÷
                  Row(
                    children: [
                      _CalcButton(
                        text: 'C',
                        color: const Color(
                          0xFFEF4444,
                        ).withOpacity(isDark ? 0.2 : 0.12),
                        textColor: const Color(0xFFEF4444),
                        height: buttonHeight,
                        onPressed: _onClearPressed,
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        icon: Icons.backspace_outlined,
                        color: buttonColor,
                        textColor: mutedColor,
                        height: buttonHeight,
                        onPressed: _onBackspacePressed,
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '%',
                        color: operatorBgColor,
                        textColor: operatorColor,
                        height: buttonHeight,
                        onPressed: () => _onOperatorPressed('%'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '÷',
                        color: operatorBgColor,
                        textColor: operatorColor,
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
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('7'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '8',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('8'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '9',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('9'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '×',
                        color: operatorBgColor,
                        textColor: operatorColor,
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
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('4'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '5',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('5'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '6',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('6'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '-',
                        color: operatorBgColor,
                        textColor: operatorColor,
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
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('1'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '2',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('2'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '3',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('3'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '+',
                        color: operatorBgColor,
                        textColor: operatorColor,
                        height: buttonHeight,
                        onPressed: () => _onOperatorPressed('+'),
                      ),
                    ],
                  ),
                  SizedBox(height: buttonSpacing),

                  // Row 5: 00, 0, =, Done
                  Row(
                    children: [
                      _CalcButton(
                        text: '00',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () {
                          _onDigitPressed('0');
                          _onDigitPressed('0');
                        },
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '0',
                        color: buttonColor,
                        textColor: textColor,
                        height: buttonHeight,
                        onPressed: () => _onDigitPressed('0'),
                      ),
                      SizedBox(width: buttonSpacing),
                      _CalcButton(
                        text: '=',
                        color: const Color(
                          0xFF3B82F6,
                        ).withOpacity(isDark ? 0.25 : 0.15),
                        textColor: const Color(0xFF3B82F6),
                        height: buttonHeight,
                        onPressed: _onEqualsPressed,
                      ),
                      SizedBox(width: buttonSpacing),
                      widget.showDoneButton
                          ? _CalcButton(
                              text: l10n.confirm,
                              color: widget.activeColor,
                              textColor: Colors.white,
                              height: buttonHeight,
                              isBold: true,
                              onPressed: _onDonePressed,
                            )
                          : _CalcButton(
                              text: '.',
                              color: buttonColor,
                              textColor: textColor,
                              height: buttonHeight,
                              onPressed: _onDecimalPressed,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTabs(bool isDark, Color textColor, Color mutedColor) {
    final bgColor = isDark ? const Color(0xFF252540) : const Color(0xFFE2E8F0);
    final selectedBgColor = const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.currencies.map((currency) {
          final isSelected = currency == widget.selectedCurrency;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onCurrencyChanged?.call(currency);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currency,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : mutedColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// زر الآلة الحاسبة
class _CalcButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final double height;
  final bool isBold;
  final VoidCallback onPressed;

  const _CalcButton({
    this.text,
    this.icon,
    required this.color,
    required this.textColor,
    required this.height,
    this.isBold = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: textColor, size: 22)
                  : Text(
                      text!,
                      style: TextStyle(
                        fontSize: text!.length > 2 ? 13 : 22,
                        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
