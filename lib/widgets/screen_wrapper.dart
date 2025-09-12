import 'package:flutter/material.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';
import 'status_bar_manager.dart';

class ScreenWrapper extends StatefulWidget {
  final Widget child;
  final Color? statusBarColor;
  final Himnario? himnario;
  
  const ScreenWrapper({
    super.key,
    required this.child,
    this.statusBarColor,
    this.himnario,
  });

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateStatusBar();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Cuando la app vuelve al primer plano, actualizar la barra de estado
      _updateStatusBar();
    }
  }
  
  @override
  void didUpdateWidget(ScreenWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusBarColor != widget.statusBarColor || 
        oldWidget.himnario != widget.himnario) {
      _updateStatusBar();
    }
  }
  
  void _updateStatusBar() {
    if (widget.statusBarColor != null) {
      StatusBarManager.setStatusBarColorWithDelay(widget.statusBarColor!);
    } else if (widget.himnario != null) {
      StatusBarManager.setStatusBarColorWithDelay(
        DynamicTheme.getColorForHimnarioSync(widget.himnario!.nombre)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
