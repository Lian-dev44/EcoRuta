# EcoRuta

Aplicación móvil desarrollada en **Flutter** para explorar destinos turísticos de Nicaragua, guardar favoritos y crear rutas personalizadas.

> Proyecto preparado para la fase de preclasificación del Hackathon Nicaragua 2026, categoría **Aficionado**.

## Descripción general

**EcoRuta** centraliza información de destinos turísticos de Nicaragua dentro de una experiencia móvil sencilla y organizada. El usuario puede registrarse, iniciar sesión, explorar lugares, buscar y filtrar destinos, consultar información detallada, guardar favoritos y crear recorridos con varios destinos.

El proyecto utiliza una arquitectura preparada para trabajar con **Firebase Authentication** y **Cloud Firestore**. Mientras Firebase no esté configurado, la aplicación activa automáticamente un modo de demostración local para permitir el desarrollo y las pruebas de interfaz.

## Problema que busca resolver

La información turística suele encontrarse distribuida entre redes sociales, mapas y diferentes sitios web. EcoRuta busca reunir en una sola aplicación la exploración de destinos, el guardado de lugares de interés y la organización de rutas.

## Objetivo general

Desarrollar una aplicación móvil funcional que permita descubrir, consultar y organizar destinos turísticos de Nicaragua mediante una interfaz clara, navegación fluida y persistencia de datos en la nube.

## Funcionalidades implementadas

### Autenticación

- Pantalla de inicio de sesión.
- Pantalla de registro.
- Validación de formularios.
- Integración en código con Firebase Authentication.
- Restauración de sesión cuando Firebase está activo.

### Inicio

- Bienvenida personalizada.
- Indicador del estado del backend.
- Destinos destacados.
- Acceso al detalle de cada destino.

### Explorar

- Búsqueda por nombre, municipio o departamento.
- Filtros por categoría.
- Listado de destinos.
- Acceso al detalle.

### Detalle del destino

- Nombre.
- Descripción.
- Categoría.
- Departamento y municipio.
- Coordenadas geográficas.
- Acción para guardar o quitar de favoritos.

### Favoritos

- Lista dinámica de destinos guardados.
- Persistencia en la colección `favoritos` cuando Firebase está conectado.

### Rutas

- Listado de rutas creadas.
- Formulario para crear una nueva ruta.
- Selección de dos o más destinos.
- Persistencia en la colección `rutas` cuando Firebase está conectado.

### Perfil

- Nombre y correo del usuario.
- Rol asignado.
- Estado del backend.
- Contadores de destinos, favoritos y rutas.
- Cierre de sesión.

## Pantallas funcionales

EcoRuta supera el mínimo de cinco pantallas solicitado para el entregable de interfaz:

1. Inicio de sesión.
2. Registro.
3. Inicio.
4. Explorar.
5. Detalle del destino.
6. Favoritos.
7. Rutas.
8. Crear ruta.
9. Perfil.

La navegación principal utiliza:

```text
Inicio | Explorar | Favoritos | Rutas | Perfil
```

## Tecnologías utilizadas

- **Flutter**
- **Dart**
- **Firebase Authentication**
- **Cloud Firestore**
- **Git**
- **GitHub**
- **GitHub Actions** para análisis, pruebas y compilación automática del APK

## Base de datos

EcoRuta utiliza **Cloud Firestore**, una base de datos NoSQL basada en documentos y colecciones.

Colecciones diseñadas:

```text
usuarios/
destinos/
categorias/
favoritos/
rutas/
auditoria/
```

Colecciones utilizadas actualmente por la interfaz:

```text
usuarios/
destinos/
favoritos/
rutas/
```

El diseño completo de la base de datos se encuentra en:

```text
docs/base-de-datos.md
```

## Arquitectura

```text
                 +----------------------+
                 |   Aplicación Flutter |
                 |       EcoRuta        |
                 +----------+-----------+
                            |
            +---------------+---------------+
            |                               |
            v                               v
+------------------------+       +-----------------------+
| Firebase Authentication|       |   Cloud Firestore     |
+------------------------+       +-----------------------+
            |                         |   |   |   |
            |                         |   |   |   +--> rutas
            |                         |   |   +------> favoritos
            |                         |   +----------> destinos
            |                         +--------------> usuarios
            |
            +---- sesión del usuario
```

Si Firebase no está configurado, la capa de repositorio cambia automáticamente a un backend local de demostración.

## Estructura del código

```text
lib/
├── main.dart
├── app.dart
├── app_controller.dart
├── app_scope.dart
├── data/
│   └── sample_data.dart
├── models/
│   ├── app_user.dart
│   ├── destination.dart
│   └── tour_route.dart
├── repositories/
│   ├── ecoruta_repository.dart
│   ├── demo_repository.dart
│   └── firebase_repository.dart
├── screens/
│   ├── auth_screens.dart
│   └── main_screens.dart
├── services/
│   └── firebase_config.dart
└── widgets/
    └── ecoruta_widgets.dart
```

## Requisitos

Para ejecutar el proyecto localmente se necesita:

- Flutter SDK estable.
- Dart SDK incluido con Flutter.
- Android Studio o Visual Studio Code.
- Android SDK.
- Emulador Android o dispositivo físico.
- Conexión a Internet para utilizar Firebase.

## Instalación básica

### 1. Clonar el repositorio

```bash
git clone https://github.com/Lian-dev44/EcoRuta.git
cd EcoRuta
```

### 2. Generar la plataforma Android

El repositorio mantiene el código fuente principal y GitHub Actions genera la plataforma Android durante la validación. Para trabajar localmente por primera vez:

```bash
flutter create --platforms=android --org com.ecoruta .
```

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Verificar el entorno

```bash
flutter doctor
```

## Ejecutar sin Firebase

Para probar interfaz, navegación y funcionalidades locales:

```bash
flutter run
```

La aplicación mostrará:

```text
Modo demostración local
```

## Ejecutar con Firebase

La configuración completa se encuentra en:

```text
docs/firebase-configuracion.md
```

Ejemplo en PowerShell:

```powershell
flutter run --dart-define=FIREBASE_API_KEY="TU_API_KEY" --dart-define=FIREBASE_APP_ID="TU_APP_ID" --dart-define=FIREBASE_MESSAGING_SENDER_ID="TU_SENDER_ID" --dart-define=FIREBASE_PROJECT_ID="TU_PROJECT_ID" --dart-define=FIREBASE_STORAGE_BUCKET="TU_BUCKET"
```

Cuando la conexión se inicializa correctamente, EcoRuta muestra:

```text
Firebase conectado
```

## Generar APK

### APK de prueba

```bash
flutter build apk --debug
```

### APK release

```bash
flutter build apk --release
```

Ruta habitual del APK release:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Validación automática

Cada cambio enviado a `main` activa GitHub Actions. El flujo ejecuta:

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Si todas las etapas terminan correctamente, GitHub publica un artefacto llamado:

```text
EcoRuta-debug-apk
```

Esto permite demostrar que el código se analiza, se prueba y se compila correctamente.

## Pruebas implementadas

El proyecto incluye pruebas automáticas para:

- Conversión del modelo `Destination`.
- Navegación por las cinco secciones principales.
- Creación de rutas desde la interfaz.

Ejecutar localmente:

```bash
flutter test
```

## Seguridad

El repositorio incluye `firestore.rules` con una base de permisos para:

- Usuarios autenticados.
- Favoritos propiedad del usuario.
- Rutas propiedad del usuario.
- Destinos y categorías administrados por rol.
- Acceso de auditoría restringido.

También se excluyen del repositorio archivos locales y credenciales mediante `.gitignore`.

## Roles previstos por la rúbrica

EcoRuta contempla los siguientes roles:

| Rol | Alcance |
|---|---|
| Usuario | Explorar destinos, gestionar favoritos y crear rutas |
| Administrador | Gestionar destinos, categorías y contenido |
| Auditor | Consultar registros y cambios sin modificar información |

La interfaz específica de Administrador y Auditor corresponde al entregable de seguridad y roles y se desarrolla como módulo independiente del flujo principal de usuario.

## Funcionalidades planificadas posteriores

Las siguientes funciones forman parte de la evolución del proyecto, pero no se presentan como terminadas en el estado actual:

- Visualización cartográfica interactiva.
- Navegación GPS.
- Imágenes almacenadas en Firebase Storage.
- Panel completo de administración.
- Panel completo de auditoría.

## Documentación adicional

```text
docs/base-de-datos.md
docs/interfaz-y-desarrollo.md
docs/estado-entregable-3.md
docs/firebase-configuracion.md
```

## Control de versiones

El proyecto utiliza Git y GitHub. Entre los cambios registrados se incluyen documentación, implementación de la interfaz, integración con Firebase, pruebas automáticas y correcciones detectadas por integración continua.

Comandos básicos:

```bash
git add .
git commit -m "descripcion del cambio"
git pull
git push
```

## Estado del proyecto

- README técnico: completado.
- Diseño NoSQL y diagrama de clases: completado.
- Interfaz con más de cinco pantallas: implementada.
- Navegación y formularios: implementados.
- Integración en código con Firebase: implementada.
- Compilación automática de APK: validada.
- Validación final contra un proyecto Firebase real: pendiente de configurar las credenciales del proyecto.

## Equipo

Proyecto desarrollado como trabajo colaborativo por un equipo de cuatro integrantes.

## Licencia

Proyecto académico y de competencia desarrollado con fines educativos y de demostración.
