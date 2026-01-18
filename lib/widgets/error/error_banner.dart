import 'dart:async';

import 'package:flutter/material.dart';

import '../../gradients.dart';
import '../../models/app_error.dart';

final Set<String> _activeMessages = <String>{};

bool _registerMessage(String message) {
  if (_activeMessages.contains(message)) {
    return false;
  }
  _activeMessages.add(message);
  return true;
}

void _unregisterMessage(String message) => _activeMessages.remove(message);

const _horizontalMargin = 16.0;
const _verticalOffset = 8.0;
const _maxWidthFraction = 0.85;

LinearGradient _getGradientForErrorLevel(ErrorLevel level) {
  switch (level) {
    case ErrorLevel.info:
      return createColorGradient(
        '青',
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    case ErrorLevel.warning:
      return createOrangeYellowGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    case ErrorLevel.error:
      return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Color(0xFFE85A3B), Color(0xFFF44336)],
      );
    case ErrorLevel.critical:
      return _createRedGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
  }
}

LinearGradient _createRedGradient({
  AlignmentGeometry begin = Alignment.topLeft,
  AlignmentGeometry end = Alignment.bottomRight,
}) {
  return LinearGradient(
    begin: begin,
    end: end,
    colors: const [Color(0xFFF44336), Color(0xFFD32F2F), Color(0xFFB71C1C)],
    stops: const [0.0, 0.5, 1.0],
  );
}

IconData _getIconForErrorLevel(ErrorLevel level) {
  switch (level) {
    case ErrorLevel.info:
      return Icons.info_outline;
    case ErrorLevel.warning:
      return Icons.warning_outlined;
    case ErrorLevel.error:
      return Icons.error_outline;
    case ErrorLevel.critical:
      return Icons.error;
  }
}

Duration _getDurationForErrorLevel(ErrorLevel level) {
  switch (level) {
    case ErrorLevel.info:
      return const Duration(seconds: 3);
    case ErrorLevel.warning:
      return const Duration(seconds: 4);
    case ErrorLevel.error:
      return const Duration(seconds: 5);
    case ErrorLevel.critical:
      return const Duration(seconds: 7);
  }
}

void showErrorBanner(
  BuildContext context,
  AppError error, {
  VoidCallback? onRetry,
}) {
  if (!context.mounted) return;

  final errorLevel = getErrorLevel(error);
  final gradient = _getGradientForErrorLevel(errorLevel);
  final icon = _getIconForErrorLevel(errorLevel);
  final duration = _getDurationForErrorLevel(errorLevel);
  final message = error.message;

  if (!_registerMessage(message)) return;

  final overlay = Overlay.of(context);
  // ignore: unnecessary_null_comparison
  if (overlay == null) {
    _unregisterMessage(message);
    return;
  }

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder:
        (context) => _FloatingErrorCard(
          message: message,
          gradient: gradient,
          icon: icon,
          duration: duration,
          onClose: () {
            _unregisterMessage(message);
            entry.remove();
          },
          onRetry: onRetry,
        ),
  );

  overlay.insert(entry);
}

void showSuccessBanner(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) return;

  if (!_registerMessage(message)) return;

  final overlay = Overlay.of(context);
  // ignore: unnecessary_null_comparison
  if (overlay == null) {
    _unregisterMessage(message);
    return;
  }

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder:
        (context) => _FloatingErrorCard(
          message: message,
          gradient: createColorGradient(
            '濃い緑',
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          icon: Icons.check_circle_outline,
          duration: duration,
          onClose: () {
            _unregisterMessage(message);
            entry.remove();
          },
        ),
  );

  overlay.insert(entry);
}

void showInfoBanner(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) return;

  if (!_registerMessage(message)) return;

  final overlay = Overlay.of(context);
  // ignore: unnecessary_null_comparison
  if (overlay == null) {
    _unregisterMessage(message);
    return;
  }

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder:
        (context) => _FloatingErrorCard(
          message: message,
          gradient: createColorGradient(
            '青',
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          icon: Icons.info_outline,
          duration: duration,
          onClose: () {
            _unregisterMessage(message);
            entry.remove();
          },
        ),
  );

  overlay.insert(entry);
}

class _FloatingErrorCard extends StatefulWidget {
  final String message;
  final LinearGradient gradient;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onRetry;
  final VoidCallback onClose;

  const _FloatingErrorCard({
    required this.message,
    required this.gradient,
    required this.icon,
    required this.duration,
    required this.onClose,
    this.onRetry,
  });

  @override
  State<_FloatingErrorCard> createState() => _FloatingErrorCardState();
}

class _FloatingErrorCardState extends State<_FloatingErrorCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slide = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      widget.onClose();
    });
  }

  void _handleRetry() {
    widget.onRetry?.call();
    _dismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * _maxWidthFraction;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + _verticalOffset,
          right: _horizontalMargin,
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.onRetry != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _handleRetry,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              '再試行',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: _dismiss,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
