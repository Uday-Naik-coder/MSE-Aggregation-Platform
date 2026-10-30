import 'package:flutter/material.dart';

enum AppButtonVariant { primary, outlined, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant   = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 52,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  }) : variant = AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final child = isLoading
        ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(label),
          ]);

    switch (variant) {
      case AppButtonVariant.outlined:
        return SizedBox(width: width, height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ));
      case AppButtonVariant.text:
        return TextButton(onPressed: isLoading ? null : onPressed, child: Text(label));
      case AppButtonVariant.danger:
        return SizedBox(width: width, height: height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error, foregroundColor: cs.onError,
              minimumSize: Size(width ?? double.infinity, height),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            onPressed: isLoading ? null : onPressed,
            child: child,
          ));
      case AppButtonVariant.primary:
        return SizedBox(width: width, height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ));
    }
  }
}
