# Configuración de Firebase — EcoRuta

EcoRuta ya incluye integración en código con:

- Firebase Authentication (correo y contraseña).
- Cloud Firestore.
- Colección `usuarios`.
- Colección `destinos`.
- Colección `favoritos`.
- Colección `rutas`.

La aplicación puede ejecutarse en dos modos:

1. **Firebase conectado**: usa autenticación y persistencia real en Firestore.
2. **Modo demostración local**: se activa automáticamente si no se suministra la configuración de Firebase.

## 1. Crear el proyecto Firebase

En Firebase Console:

1. Crear un proyecto llamado, por ejemplo, **EcoRuta**.
2. Crear la base de datos **Cloud Firestore**.
3. Habilitar **Authentication > Sign-in method > Email/Password**.
4. Registrar una aplicación Android.

Paquete recomendado:

```text
com.ecoruta.ecoruta
```

## 2. Preparar el proyecto Flutter local

Después de clonar el repositorio:

```bash
git clone https://github.com/Lian-dev44/EcoRuta.git
cd EcoRuta
flutter create --platforms=android --org com.ecoruta .
flutter pub get
```

El comando `flutter create` genera los archivos Android estándar que no es necesario mantener manualmente durante esta etapa del prototipo.

## 3. Obtener los valores de Firebase

Se necesitan:

- API Key.
- App ID.
- Messaging Sender ID.
- Project ID.
- Storage Bucket (opcional para este entregable).

El repositorio incluye:

```text
firebase.env.example.json
```

Crear una copia local llamada:

```text
firebase.env.json
```

Ejemplo:

```json
{
  "FIREBASE_API_KEY": "TU_API_KEY",
  "FIREBASE_APP_ID": "TU_APP_ID",
  "FIREBASE_MESSAGING_SENDER_ID": "TU_MESSAGING_SENDER_ID",
  "FIREBASE_PROJECT_ID": "TU_PROJECT_ID",
  "FIREBASE_STORAGE_BUCKET": "TU_STORAGE_BUCKET"
}
```

`firebase.env.json` está excluido mediante `.gitignore` para que la configuración local no se publique accidentalmente.

## 4. Ejecutar con Firebase

```bash
flutter run --dart-define-from-file=firebase.env.json
```

Al iniciar correctamente, EcoRuta muestra en la interfaz:

```text
Firebase conectado
```

Si el archivo no se suministra o sus valores están vacíos, la aplicación muestra:

```text
Modo demostración local
```

## 5. Flujo de prueba del backend

1. Crear una cuenta desde la pantalla de registro.
2. Comprobar que el usuario aparece en Firebase Authentication.
3. Comprobar que se crea `usuarios/{uid}` en Firestore.
4. Si `destinos` está vacío, abrir **Perfil** y pulsar **Cargar destinos iniciales en Firestore**.
5. Abrir **Explorar** y confirmar que los destinos se leen desde Firestore.
6. Guardar un destino como favorito.
7. Verificar el documento en `favoritos`.
8. Quitar el favorito y comprobar que el documento desaparece.
9. Crear una ruta con al menos dos destinos.
10. Verificar el documento en `rutas`.
11. Cerrar la aplicación y volver a abrirla.
12. Comprobar que la sesión y los datos persistentes se restauran correctamente.

## 6. Estructura usada

```text
usuarios/{uid}
destinos/{idDestino}
favoritos/{uid}_{idDestino}
rutas/{idRuta}
```

## 7. Compilar un APK conectado a Firebase

Para generar una APK de depuración con la configuración del proyecto:

```bash
flutter build apk --debug --dart-define-from-file=firebase.env.json
```

Para una compilación release posterior:

```bash
flutter build apk --release --dart-define-from-file=firebase.env.json
```

## 8. Nota de seguridad

Durante las primeras pruebas puede utilizarse una configuración temporal de Firestore que permita validar el flujo. Antes de la entrega deben aplicarse reglas de seguridad por usuario y rol. Ese trabajo forma parte del entregable de seguridad y buenas prácticas.
