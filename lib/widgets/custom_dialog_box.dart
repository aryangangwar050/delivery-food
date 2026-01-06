import 'package:flutter/material.dart';

import '../utils/color_res.dart';
import '../utils/size_config.dart';

/// Shows a custom animated confirmation dialog.
/// Returns true when user confirms, false when cancelled.
Future<bool?> showCustomDialog(
  BuildContext context, {
  required String title,
  required String description,
  String confirmText = 'Logout',
  String cancelText = 'Cancel',
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Confirm',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      // This builder is not used for the transition, return empty container
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: Center(
            child: _DialogContent(
              title: title,
              description: description,
              confirmText: confirmText,
              cancelText: cancelText,
            ),
          ),
        ),
      );
    },
  );
}

class _DialogContent extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;

  const _DialogContent({
    Key? key,
    required this.title,
    required this.description,
    required this.confirmText,
    required this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    SizeConfig.init(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.scale(28)),
        padding: EdgeInsets.all(SizeConfig.scale(18)),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: SizeConfig.scale(4)),
            Container(
              height: SizeConfig.scale(64),
              width: SizeConfig.scale(64),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, size: SizeConfig.scale(36), color: theme.colorScheme.primary),
            ),
            SizedBox(height: SizeConfig.scale(12)),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: SizeConfig.fs(18)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.scale(8)),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: SizeConfig.fs(14)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.scale(18)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelText),
                  ),
                ),
                SizedBox(width: SizeConfig.scale(12)),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.danger, // emphasize destructive action
                      foregroundColor: ColorRes.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmText),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
