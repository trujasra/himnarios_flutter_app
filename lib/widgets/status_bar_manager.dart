import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/himnario.dart';
import '../theme/app_theme.dart';

class StatusBarManager {
  static void setStatusBarColorForHimnario(Himnario himnario) {
    // Obtener el color principal del himnario
    final color = AppTheme.getColorForHimnario(himnario.color);
    
    // Determinar si el color es claro u oscuro para ajustar los iconos
    final isLightColor = _isLightColor(color);
    
    // Configurar la barra de estado con el color del himnario
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: isLightColor ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLightColor ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: color, // También cambiar la barra de navegación
      ),
    );
    
    print('StatusBar configurado para himnario ${himnario.nombre} con color: $color');
  }
  
  static void setStatusBarColorForGradient(List<Color> gradientColors) {
    // Usar el primer color del gradiente para determinar el brillo
    final primaryColor = gradientColors.first;
    final isLightColor = _isLightColor(primaryColor);
    
    // Configurar la barra de estado con el color del gradiente
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: isLightColor ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLightColor ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: primaryColor, // También cambiar la barra de navegación
      ),
    );
    
    print('StatusBar configurado para gradiente con color: $primaryColor');
  }
  
  // Método alternativo para configurar la barra de estado
  static void setStatusBarColor(Color color) {
    final isLightColor = _isLightColor(color);
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: isLightColor ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLightColor ? Brightness.light : Brightness.dark,
      ),
    );
    
    print('StatusBar configurado con color: $color');
  }
  
  // Método para configurar la barra de estado con delay para asegurar que se aplique
  static void setStatusBarColorWithDelay(Color color) {
    // Configurar inmediatamente
    setStatusBarColor(color);
    
    // Configurar de nuevo con múltiples delays para asegurar que se aplique
    Future.delayed(const Duration(milliseconds: 50), () {
      setStatusBarColor(color);
    });
    
    Future.delayed(const Duration(milliseconds: 150), () {
      setStatusBarColor(color);
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      setStatusBarColor(color);
    });
  }
  
  static bool _isLightColor(Color color) {
    // Calcular el brillo del color
    final brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness > 128; // Si es mayor a 128, es un color claro
  }
  
  // Método para forzar la actualización de la barra de estado
  static void forceUpdateStatusBar() {
    // Forzar una actualización de la UI con un pequeño delay
    Future.delayed(const Duration(milliseconds: 50), () {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
      );
    });
  }
}

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

class _StatusBarWrapperState extends State<StatusBarWrapper> with WidgetsBindingObserver {
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
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Cuando la app vuelve al primer plano, actualizar la barra de estado
      _updateStatusBar();
    }
  }
  
  void _updateStatusBar() {
    if (widget.himnario != null) {
      StatusBarManager.setStatusBarColorForHimnario(widget.himnario!);
    } else if (widget.gradientColors != null) {
      StatusBarManager.setStatusBarColorForGradient(widget.gradientColors!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
