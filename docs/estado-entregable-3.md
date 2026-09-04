# Estado del entregable 3 — Interfaz y desarrollo

## Criterio

Implementación en código de la interfaz gráfica con al menos cinco pantallas funcionales, navegación fluida, coherencia estética, interacción con backend cuando aplique y una experiencia de usuario sólida.

## Cobertura actual

- [x] Más de cinco pantallas implementadas en Flutter.
- [x] Navegación inferior y navegación secundaria.
- [x] Formularios de inicio de sesión, registro y creación de rutas.
- [x] Validaciones y mensajes de error.
- [x] Búsqueda y filtros.
- [x] Favoritos.
- [x] Rutas con múltiples destinos.
- [x] Integración en código con Firebase Authentication.
- [x] Integración en código con Cloud Firestore.
- [x] Persistencia remota de usuarios, favoritos y rutas cuando Firebase está configurado.
- [x] Modo local de respaldo para desarrollo sin configuración externa.
- [x] Identidad visual coherente con Material 3.
- [x] `flutter analyze` ejecutado correctamente en GitHub Actions.
- [x] Pruebas automáticas ejecutadas correctamente en GitHub Actions.
- [x] APK de depuración compilado correctamente en GitHub Actions.
- [x] APK publicado como artefacto de la ejecución automática.
- [ ] Validación final en dispositivo con el proyecto Firebase real de EcoRuta.

## Validación automática

La ejecución **Flutter CI #3** finalizó correctamente. El flujo validó:

1. Instalación de Flutter y dependencias.
2. Generación de la plataforma Android necesaria para compilación.
3. Análisis estático con `flutter analyze`.
4. Ejecución de pruebas con `flutter test`.
5. Compilación de `app-debug.apk`.
6. Publicación del APK como artefacto de GitHub Actions.

Posteriormente se añadieron pruebas de navegación que recorren las cinco secciones principales y verifican la creación de una ruta desde la interfaz.

## Backend implementado

Cuando se suministra la configuración del proyecto Firebase, las siguientes operaciones utilizan backend real:

- Registro de usuarios: Firebase Authentication + `usuarios`.
- Inicio de sesión: Firebase Authentication.
- Lectura de destinos: `destinos`.
- Guardar/quitar favoritos: `favoritos`.
- Crear y consultar rutas: `rutas`.
- Restaurar la sesión del usuario.

La aplicación muestra de forma visible si está ejecutándose con **Firebase conectado** o en **Modo demostración local**.

## Prueba final requerida con Firebase real

Para cerrar completamente la validación externa del backend debe ejecutarse la app con el proyecto Firebase real de EcoRuta y comprobar:

1. Registro.
2. Inicio de sesión.
3. Lectura de destinos desde Firestore.
4. Escritura y eliminación de favoritos.
5. Creación y persistencia de rutas.
6. Persistencia después de cerrar y volver a abrir la aplicación.

La configuración necesaria está documentada en `docs/firebase-configuracion.md`.
