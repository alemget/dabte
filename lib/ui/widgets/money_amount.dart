import 'package:flutter/material.dart';

import 'currency_display_helper.dart';

class MoneyAmount extends StatelessWidget {
  final double amount;
  final String currencyCode;
  final TextStyle? style;
  final Color? color;
  final int fractionDigits;
  final bool showIcon;
  final bool showCode;
  final bool showSign;

  const MoneyAmount({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.style,
    this.color,
    this.fractionDigits = 2,
    this.showIcon = true,
    this.showCode = true,
    this.showSign = false,
  });

  String _format(double value) {
    final fixed = value.toStringAsFixed(fractionDigits);
    if (fractionDigits > 0 && fixed.endsWith('.' + '0' * fractionDigits)) {
      return fixed.substring(0, fixed.length - (fractionDigits + 1));
    }
    return fixed;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color;
    final text = _format(amount);
    final sign = showSign ? (amount > 0 ? '+' : amount < 0 ? '-' : '') : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          CurrencyDisplayHelper.getIcon(
            currencyCode,
            size: (style?.fontSize ?? 12) + 2,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          '$sign$text',
          style: (style ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))
              .copyWith(color: effectiveColor),
        ),
        if (showCode) ...[
          const SizedBox(width: 6),
          Text(
            currencyCode,
            style: (style ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)).copyWith(
              color: effectiveColor?.withAlpha(220) ?? Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
