import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// آلة حاسبة احترافية مدمجة لإدخال المبالغ
class CalculatorKeyboard extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onValueChanged;
  final Color activeColor;

  const CalculatorKeyboard({
    super.key,
    this.initialValue = '',
    required this.onValueChanged,
    this.activeColor = const Color(0xFF10B981),
  });

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard> {
  String _display = '0';
  String _expression = '';
  double? _result;
  String? _lastOperator;
  bool _shouldResetDisplay = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue.isNotEmpty) {
      _display = widget.initialValue;
      _result = double.tryParse(widget.initialValue);
    }
  }

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
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
      if (_lastOperator != null && !_shouldResetDisplay) {
        _calculateResult();
      }
      _result = double.tryParse(_display);
      _lastOperator = operator;
      _expression = '$_display $operator';
      _shouldResetDisplay = true;
    });
  }

  void _calculateResult() {
    if (_result == null || _lastOperator == null) return;

    final currentValue = double.tryParse(_display) ?? 0;
    double newResult;

    switch (_lastOperator) {
      case '+':
        newResult = _result! + currentValue;
        break;
      case '-':
        newResult = _result! - currentValue;
        break;
      case '×':
        newResult = _result! * currentValue;
        break;
      case '÷':
        if (currentValue == 0) {
          newResult = 0;
        } else {
          newResult = _result! / currentValue;
        }
        break;
      default:
        return;
    }

    setState(() {
      // تنسيق النتيجة بدون أصفار زائدة
      if (newResult == newResult.toInt()) {
        _display = newResult.toInt().toString();
      } else {
        _display = newResult.toStringAsFixed(2);
      }
      _result = newResult;
      _expression = '';
      _lastOperator = null;
      _shouldResetDisplay = true;
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
      _expression = '';
      _result = null;
      _lastOperator = null;
      _shouldResetDisplay = false;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF1F5F9);
    final buttonColor = isDark ? const Color(0xFF2A2A3E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark ? Colors.grey[500]! : const Color(0xFF64748B);
    final operatorColor = const Color(0xFF6366F1);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شاشة العرض
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252540) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // المعادلة
                if (_expression.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _expression,
                      style: TextStyle(fontSize: 16, color: mutedColor),
                    ),
                  ),
                // الرقم الحالي
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: widget.activeColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // أزرار الآلة الحاسبة
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // الصف الأول: C, ⌫, ÷
                Row(
                  children: [
                    _CalcButton(
                      text: 'C',
                      color: const Color(0xFFEF4444),
                      textColor: Colors.white,
                      onPressed: _onClearPressed,
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      icon: Icons.backspace_outlined,
                      color: buttonColor,
                      textColor: mutedColor,
                      onPressed: _onBackspacePressed,
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '%',
                      color: buttonColor,
                      textColor: operatorColor,
                      onPressed: () => _onOperatorPressed('%'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '÷',
                      color: operatorColor.withOpacity(0.15),
                      textColor: operatorColor,
                      onPressed: () => _onOperatorPressed('÷'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // الصف الثاني: 7, 8, 9, ×
                Row(
                  children: [
                    _CalcButton(
                      text: '7',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('7'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '8',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('8'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '9',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('9'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '×',
                      color: operatorColor.withOpacity(0.15),
                      textColor: operatorColor,
                      onPressed: () => _onOperatorPressed('×'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // الصف الثالث: 4, 5, 6, -
                Row(
                  children: [
                    _CalcButton(
                      text: '4',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('4'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '5',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('5'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '6',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('6'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '-',
                      color: operatorColor.withOpacity(0.15),
                      textColor: operatorColor,
                      onPressed: () => _onOperatorPressed('-'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // الصف الرابع: 1, 2, 3, +
                Row(
                  children: [
                    _CalcButton(
                      text: '1',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('1'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '2',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('2'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '3',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('3'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '+',
                      color: operatorColor.withOpacity(0.15),
                      textColor: operatorColor,
                      onPressed: () => _onOperatorPressed('+'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // الصف الخامس: 00, 0, ., =
                Row(
                  children: [
                    _CalcButton(
                      text: '00',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () {
                        _onDigitPressed('0');
                        _onDigitPressed('0');
                      },
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '0',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: () => _onDigitPressed('0'),
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '.',
                      color: buttonColor,
                      textColor: textColor,
                      onPressed: _onDecimalPressed,
                    ),
                    const SizedBox(width: 8),
                    _CalcButton(
                      text: '=',
                      color: widget.activeColor,
                      textColor: Colors.white,
                      onPressed: _onEqualsPressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
  final VoidCallback onPressed;

  const _CalcButton({
    this.text,
    this.icon,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon, color: textColor, size: 24)
                : Text(
                    text!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
