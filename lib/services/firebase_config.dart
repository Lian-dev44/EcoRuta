import 'package:firebase_core/firebase_core.dart';

/// Configuración cliente del proyecto Firebase de EcoRuta.
///
/// Los valores de configuración de una app cliente Firebase identifican el
/// proyecto y permiten inicializar los SDK móviles. No contienen credenciales
/// administrativas ni claves de servicio. Se mantienen los dart-defines como
/// mecanismo de override para otros entornos de desarrollo.
class EcoRutaFirebaseConfig {
  static const apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyCkOKPDX92WymtJuw8KwzYdOsZGzfhZkIs',
  );

  static const appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:1044056559652:android:f189cd532170d8999ac8b1',
  );

  static const messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1044056559652',
  );

  static const projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'ecoruta-67c18',
  );

  static const storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'ecoruta-67c18.firebasestorage.app',
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
      );
}
