import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_colors.dart';

/// Shows an animated slide-up toast with an Undo action.
/// Returns a cancel callback — call it to dismiss the toast early (plays exit animation).
VoidCallback showUndoToast({
  required BuildContext context,
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 4),
}) {
  final key = GlobalKey<_UndoToastState>();
  late OverlayEntry entry;

  void removeEntry() {
    if (entry.mounted) entry.remove();
  }

  entry = OverlayEntry(
    builder: (_) => _UndoToast(
      key: key,
      message: message,
      onUndo: onUndo,
      onRemove: removeEntry,
      duration: duration,
    ),
  );

  Overlay.of(context).insert(entry);
  return () => key.currentState?.dismiss();
}

class _UndoToast extends StatefulWidget {
  final String message;
  final VoidCallback onUndo;
  final VoidCallback onRemove;
  final Duration duration;

  const _UndoToast({
    super.key,
    required this.message,
    required this.onUndo,
    required this.onRemove,
    required this.duration,
  });

  @override
  State<_UndoToast> createState() => _UndoToastState();
}

class _UndoToastState extends State<_UndoToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _timer = Timer(widget.duration, dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void dismiss() {
    _timer?.cancel();
    if (!mounted) return;
    _ctrl.reverse().then((_) {
      if (mounted) widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: AppSpacing.xl + MediaQuery.of(context).padding.bottom,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral700,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTypography.body1
                        .copyWith(color: AppColors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onUndo();
                    dismiss();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Undo',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
