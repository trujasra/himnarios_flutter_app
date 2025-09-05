import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';

class StatusBarManager {
  /// Configura la barra de estado según un Himnario
  static void setStatusBarColorForHimnario(Himnario himnario) {
    final color = _getColorForHimnario(himnario.nombre);
    _setStatusBarColor(color);
    print(
      'StatusBar configurado para himnario ${himnario.nombre} con color: $color',
    );
  }

  /// Configura la barra de estado según un gradiente
  static void setStatusBarColorForGradient(List<Color> gradientColors) {
    final primaryColor = gradientColors.first;
    _setStatusBarColor(primaryColor);
    print('StatusBar configurado para gradiente con color: $primaryColor');
  }

  /// Configura la barra de estado con color genérico
  static void setStatusBarColor(Color color) => _setStatusBarColor(color);

  /// Configura la barra de estado con delay para asegurar que se aplique
  static void setStatusBarColorWithDelay(Color color) {
    _setStatusBarColor(color);
    Future.delayed(
      const Duration(milliseconds: 50),
      () => _setStatusBarColor(color),
    );
    Future.delayed(
      const Duration(milliseconds: 150),
      () => _setStatusBarColor(color),
    );
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _setStatusBarColor(color),
    );
  }

  /// Método interno para aplicar el color y el brillo
  static void _setStatusBarColor(Color color) {
    final isLight = _isLightColor(color);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark, // íconos negros
        // systemNavigationBarIconBrightness: isLight
        //     ? Brightness.dark
        //     : Brightness.light,
      ),
    );
  }

  /// Determina si un color es claro
  static bool _isLightColor(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final brightness = (r * 299 + g * 587 + b * 114) / 1000;
    return brightness > 128;
  }

  /// Retorna el color según el himnario
  static Color _getColorForHimnario(String nombre) {
    final lower = nombre.toLowerCase();
    if (lower.contains('bendición del cielo')) return AppTheme.bendicionColor;
    if (lower.contains('coros cristianos')) return AppTheme.corosColor;
    if (lower.contains('cala')) return AppTheme.calaColor;
    if (lower.contains('poder del')) return AppTheme.poderColor;
    if (lower.contains('lluvias de')) return AppTheme.lluviasColor;
    return AppTheme.getColorForHimnario('default');
  }
}

/// Widget que actualiza automáticamente la status bar
class StatusBarWrapper extends StatefulWidget {
  final Widget child;
  final Himnario? himnario;
  final List<Color>? gradientColors;

  const StatusBarWrapper({
    super.key,
    required this.child,
    this.himnario,
    this.gradientColors,
  });

  @override
  State<StatusBarWrapper> createState() => _StatusBarWrapperState();
}

class _StatusBarWrapperState extends State<StatusBarWrapper>
    with WidgetsBindingObserver {
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
  void didUpdateWidget(StatusBarWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.himnario != widget.himnario ||
        oldWidget.gradientColors != widget.gradientColors) {
      _updateStatusBar();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updateStatusBar();
  }

  void _updateStatusBar() {
    if (widget.himnario != null) {
      StatusBarManager.setStatusBarColorWithDelay(
        StatusBarManager._getColorForHimnario(widget.himnario!.nombre),
      );
    } else if (widget.gradientColors != null) {
      StatusBarManager.setStatusBarColorWithDelay(widget.gradientColors!.first);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
