import 'package:flutter/material.dart';
import 'status_bar_manager.dart';
import '../main.dart';

mixin RouteAwareMixin<T extends StatefulWidget> on State<T> implements RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Se llama cuando regresamos a esta pantalla
    onReturnToScreen();
  }

  @override
  void didPush() {
    // Se llama cuando navegamos a esta pantalla
    onEnterScreen();
  }

  @override
  void didPop() {
    // Se llama cuando salimos de esta pantalla
  }

  @override
  void didPushNext() {
    // Se llama cuando navegamos a otra pantalla desde esta
  }

  // Métodos que deben ser implementados por las clases que usen este mixin
  void onEnterScreen() {}
  void onReturnToScreen() {}
}
