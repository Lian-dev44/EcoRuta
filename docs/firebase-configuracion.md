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

1. Crear un proyecto para EcoRuta.
2. Crear la base de datos Cloud Firestore.
3. Habilitar Authentication > Sign-in method > Email/Password.
4. Registrar una aplicación Android.

Paquete recomendado:

```text
com.ecoruta.ecoruta
```

## 2. Obtener los valores de configuración

Se necesitan los siguientes valores del proyecto:

- API Key.
- App ID.
- Messaging Sender ID.
- Project ID.
- Storage Bucket (opcional para este entregable).

EcoRuta no guarda estos valores directamente en GitHub.

## 3. Ejecutar con Firebase

Ejemplo:

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY="TU_API_KEY" \
  --dart-define=FIREBASE_APP_ID="TU_APP_ID" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="TU_SENDER_ID" \
  --dart-define=FIREBASE_PROJECT_ID="TU_PROJECT_ID" \
  --dart-define=FIREBASE_STORAGE_BUCKET="TU_BUCKET"
```

En PowerShell se puede ejecutar en una sola línea:

```powershell
flutter run --dart-define=FIREBASE_API_KEY="TU_API_KEY" --dart-define=FIREBASE_APP_ID="TU_APP_ID" --dart-define=FIREBASE_MESSAGING_SENDER_ID="TU_SENDER_ID" --dart-define=FIREBASE_PROJECT_ID="TU_PROJECT_ID" --dart-define=FIREBASE_STORAGE_BUCKET="TU_BUCKET"
```

Al iniciar correctamente, la interfaz muestra:

```text
Firebase conectado
```

## 4. Flujo de prueba del backend

1. Crear una cuenta desde la pantalla de registro.
2. Se crea el usuario en Firebase Authentication.
3. Se crea su perfil en `usuarios/{uid}`.
4. Si `destinos` está vacío, abrir **Perfil** y pulsar **Cargar destinos iniciales en Firestore**.
5. Abrir **Explorar**.
6. Guardar un destino como favorito.
7. Verificar el documento creado en `favoritos`.
8. Crear una ruta con al menos dos destinos.
9. Verificar el documento creado en `rutas`.
10. Cerrar la aplicación, volver a abrirla e iniciar sesión para comprobar persistencia.

## 5. Estructura usada

```text
usuarios/{uid}
destinos/{idDestino}
favoritos/{uid}_{idDestino}
rutas/{idRuta}
```

## 6. Nota de seguridad

Para la preclasificación se puede iniciar Firestore temporalmente en modo de prueba mientras se valida la integración. Antes de la entrega final deben configurarse reglas de seguridad por usuario y rol. Ese trabajo corresponde también al entregable de seguridad y buenas prácticas.
