import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class _MacOSTitlebarSafeArea extends StatefulWidget {
  final Widget child;

  const _MacOSTitlebarSafeArea({required this.child});

  @override
  State<_MacOSTitlebarSafeArea> createState() => _MacOSTitlebarSafeAreaState();
}

class _MacOSTitlebarSafeAreaState extends State<_MacOSTitlebarSafeArea> {
  double _titlebarHeight = 0.0;
  Timer? _settleTimer;

  /// Reads the titlebar height. The native value can be transiently wrong
  /// (even negative) while the window is being resized, zoomed, or
  /// entering/exiting fullscreen, and negative padding is not allowed.
  Future<double> _readTitlebarHeight() async =>
      max(0.0, await Window.getTitlebarHeight());

  /// Schedules an update of the titlebar height, if it has changed.
  ///
  /// The new height is applied only once the window has settled: besides the
  /// native value being unreliable mid-transition, relayouting while the
  /// window is still resizing can crash the Impeller renderer.
  Future<void> _updateTitlebarHeight() async {
    final newTitlebarHeight = await _readTitlebarHeight();
    if (!mounted || _titlebarHeight == newTitlebarHeight) return;

    _settleTimer?.cancel();
    _settleTimer = Timer(const Duration(milliseconds: 100), () async {
      final settledTitlebarHeight = await _readTitlebarHeight();
      if (!mounted || _titlebarHeight == settledTitlebarHeight) return;
      setState(() {
        _titlebarHeight = settledTitlebarHeight;
      });

      // The window may still have been transitioning; check again later so a
      // transient value does not stick until the next unrelated rebuild.
      _settleTimer = Timer(
        const Duration(milliseconds: 500),
        _updateTitlebarHeight,
      );
    });
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateTitlebarHeight();

    return Padding(
      padding: EdgeInsets.only(top: _titlebarHeight),
      child: widget.child,
    );
  }
}

class TitlebarSafeArea extends StatelessWidget {
  final Widget child;

  /// A widget that provides a safe area for its child.
  ///
  /// The safe area is the area on the top of the window that is not covered by
  /// the title bar. This widget has no effect when the full-size content view
  /// is disabled or when the app is running on a platform other than macOS.
  ///
  /// Example:
  /// ```dart
  /// TitlebarSafeArea(
  ///  child: Text('Hello World'),
  /// )
  /// ```
  const TitlebarSafeArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) return child;

    return _MacOSTitlebarSafeArea(child: child);
  }
}
