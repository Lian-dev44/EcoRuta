import 'package:flutter/widgets.dart';

import 'app_controller.dart';

class EcoRutaScope extends InheritedNotifier<AppController> {
  const EcoRutaScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<EcoRutaScope>();
    assert(scope != null, 'EcoRutaScope no encontrado');
    return scope!.notifier!;
  }
}
