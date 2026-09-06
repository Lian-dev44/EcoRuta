# EcoRuta

Aplicación móvil desarrollada en **Flutter** para descubrir destinos turísticos de Nicaragua, consultar información de lugares, guardar favoritos, crear rutas personalizadas y utilizar navegación basada en GPS sobre un mapa interactivo.

> Proyecto preparado para la fase de preclasificación del **Hackathon Nicaragua 2026**, categoría **Aficionado**.

## Descripción general

**EcoRuta** es una aplicación móvil orientada al turismo dentro de Nicaragua. Su propósito es reunir en una sola experiencia digital la exploración de destinos, la consulta de información turística y la planificación de recorridos.

El usuario puede registrarse e iniciar sesión, explorar destinos, buscar y filtrar lugares, consultar detalles, guardar favoritos, crear rutas con varios destinos y visualizar recorridos sobre un mapa. La aplicación también puede utilizar la ubicación del teléfono para calcular rutas desde la posición actual del usuario.

EcoRuta utiliza **Firebase Authentication** para autenticación y **Cloud Firestore** para persistencia de datos. Además, integra **OpenStreetMap** para la visualización cartográfica y **OSRM** para el cálculo de rutas vehiculares.

## Problema que busca resolver

La información turística de Nicaragua suele encontrarse distribuida entre redes sociales, mapas, recomendaciones y diferentes sitios web. Esto puede dificultar la búsqueda de destinos y la organización de un recorrido.

EcoRuta busca centralizar esa experiencia permitiendo descubrir lugares turísticos y organizar rutas desde una misma aplicación móvil.

## Objetivo general

Desarrollar una aplicación móvil funcional que permita descubrir, consultar y organizar destinos turísticos de Nicaragua mediante una interfaz clara, navegación fluida, geolocalización y persistencia de datos en la nube.

## Versión actual

```text
EcoRuta 0.4.0+4
```

## Funcionalidades implementadas

### Autenticación

- Inicio de sesión con correo y contraseña.
- Registro de nuevos usuarios.
- Validación de formularios.
- Integración con Firebase Authentication.
- Restauración de sesión.
- Cierre de sesión.

### Inicio

- Bienvenida al usuario.
- Acceso a destinos destacados.
- Acceso rápido a favoritos.
- Acceso al detalle de cada destino.
- Identidad visual de EcoRuta integrada en la interfaz.

### Explorar

- Listado de destinos turísticos.
- Búsqueda por nombre, municipio o departamento.
- Filtros por categoría.
- Acceso al detalle de cada destino.
- Acceso rápido a favoritos.

### Detalle del destino

Cada destino puede mostrar información como:

- Nombre.
- Descripción.
- Categoría.
- Departamento.
- Municipio.
- Coordenadas geográficas.
- Acción para guardar o eliminar de favoritos.

### Favoritos

- Lista dinámica de destinos guardados.
- Persistencia en Cloud Firestore.
- Cada usuario gestiona únicamente sus propios favoritos.

### Mapa interactivo

- Mapa de Nicaragua mediante OpenStreetMap.
- Marcadores para los destinos disponibles.
- Marcador de ubicación actual del usuario.
- Búsqueda de destinos directamente desde el mapa.
- Centrado automático en la posición del usuario.
- Opción para seguir la posición durante la navegación.

### GPS y navegación

- Solicitud y validación de permisos de ubicación.
- Seguimiento continuo de la posición mediante GPS.
- Cálculo de rutas desde la ubicación actual.
- Visualización del recorrido sobre el mapa.
- Distancia aproximada de la ruta.
- Duración estimada del recorrido.
- Recalculo de la ruta mientras el usuario se desplaza.
- Avance automático entre destinos de una ruta personalizada.
- Detección de llegada al destino.
- Opción para detener o continuar el seguimiento de navegación.

> La navegación actual está orientada a mostrar y recalcular recorridos. No incluye navegación por voz, información de tráfico en tiempo real ni asistencia de carriles.

### Rutas personalizadas

- Creación de rutas con dos o más destinos.
- Guardado de rutas en Cloud Firestore.
- Visualización de rutas guardadas.
- Apertura de una ruta guardada directamente en el mapa.
- Recorrido respetando el orden de los destinos seleccionados.
- Generación de rutas sugeridas a partir de destinos cercanos.
- Guardado de una ruta sugerida en “Mis rutas”.

### Perfil

- Nombre del usuario.
- Correo electrónico.
- Rol asignado.
- Estado del backend.
- Contadores de destinos, favoritos y rutas.
- Cierre de sesión.
- Acción administrativa de sincronización de destinos cuando el usuario posee rol `admin`.

## Pantallas y navegación

EcoRuta supera el mínimo de cinco pantallas funcionales solicitado para el entregable de interfaz.

Entre las pantallas y vistas disponibles se encuentran:

1. Inicio de sesión.
2. Registro.
3. Inicio.
4. Explorar.
5. Detalle del destino.
6. Favoritos.
7. Mapa.
8. Rutas.
9. Creación y gestión de rutas.
10. Perfil.

La navegación principal utiliza cinco secciones:

```text
Inicio | Explorar | Mapa | Rutas | Perfil
```

Los favoritos se encuentran disponibles mediante accesos directos desde Inicio y Explorar.

## Tecnologías utilizadas

| Tecnología | Uso en EcoRuta |
|---|---|
| Flutter | Desarrollo de la aplicación móvil |
| Dart | Lenguaje principal |
| Firebase Authentication | Registro, autenticación y sesiones |
| Cloud Firestore | Persistencia NoSQL |
| flutter_map | Visualización del mapa |
| OpenStreetMap | Proveedor de cartografía |
| Geolocator | Ubicación y seguimiento GPS |
| OSRM | Cálculo de rutas vehiculares |
| HTTP | Comunicación con el servicio de rutas |
| Git | Control de versiones |
| GitHub | Repositorio del proyecto |
| GitHub Actions | Análisis, pruebas y compilación automática del APK |

## Base de datos

EcoRuta utiliza **Cloud Firestore**, una base de datos NoSQL basada en documentos y colecciones.

Colecciones contempladas en el diseño:

```text
usuarios/
destinos/
categorias/
favoritos/
rutas/
auditoria/
```

### Uso general de las colecciones

- `usuarios`: información básica del usuario y rol.
- `destinos`: catálogo turístico.
- `categorias`: clasificación de destinos.
- `favoritos`: relación entre usuario y destinos guardados.
- `rutas`: rutas personalizadas de cada usuario.
- `auditoria`: registros destinados al control y seguimiento de cambios.

La documentación del modelo de datos se encuentra en:

```text
docs/base-de-datos.md
```

## Arquitectura general

```text
                    +----------------------+
                    |   Aplicación Flutter |
                    |       EcoRuta        |
                    +----------+-----------+
                               |
              +----------------+----------------+
              |                |                |
              v                v                v
 +----------------------+  +-----------+  +----------------+
 | Firebase             |  | Firestore |  | Mapa y rutas   |
 | Authentication       |  | NoSQL     |  | OSM + OSRM     |
 +----------------------+  +-----------+  +----------------+
          |                    |                |
          |                    |                +--> GPS
          |                    +--> destinos    +--> recorrido
          |                    +--> favoritos   +--> distancia
          |                    +--> rutas       +--> duración
          |                    +--> usuarios
          |
          +--> sesión del usuario
```

## Estructura principal del código

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
├── navigation/
│   └── map_navigation_request.dart
├── repositories/
│   ├── ecoruta_repository.dart
│   ├── demo_repository.dart
│   └── firebase_repository.dart
├── screens/
│   ├── auth_screens.dart
│   ├── main_screens.dart
│   ├── main_shell.dart
│   ├── map_screen.dart
│   └── routes_navigation_screen.dart
├── services/
│   ├── firebase_config.dart
│   ├── location_service.dart
│   └── routing_service.dart
└── widgets/
    └── ecoruta_widgets.dart
```

También se utilizan scripts auxiliares en:

```text
tool/generate_branding.py
tool/configure_android.py
```

## Requisitos para ejecutar el proyecto

- Flutter SDK estable.
- Dart SDK incluido con Flutter.
- Android Studio o Visual Studio Code.
- Android SDK.
- Emulador Android o dispositivo físico.
- Python 3 para los scripts auxiliares del proyecto.
- Conexión a Internet para Firebase, mapas y cálculo de rutas.
- GPS o ubicación habilitada para probar navegación desde la posición real.

## Instalación básica

### 1. Clonar el repositorio

```bash
git clone https://github.com/Lian-dev44/EcoRuta.git
cd EcoRuta
```

### 2. Generar la plataforma Android

Si la carpeta Android todavía no existe en el entorno local:

```bash
flutter create --platforms=android --org com.ecoruta .
```

### 3. Generar branding y configuración Android

```bash
python3 tool/generate_branding.py
python3 tool/configure_android.py
```

En Windows también puede utilizarse:

```powershell
python tool/generate_branding.py
python tool/configure_android.py
```

### 4. Instalar dependencias

```bash
flutter pub get
```

### 5. Verificar el entorno

```bash
flutter doctor
```

## Ejecución del sistema

Con un emulador o teléfono Android conectado:

```bash
flutter run
```

La configuración cliente de Firebase del proyecto está integrada en la aplicación. También puede reemplazarse mediante `--dart-define` para utilizar otro entorno.

Si Firebase no puede inicializarse, EcoRuta conserva un repositorio local de demostración para facilitar pruebas básicas de interfaz.

## Permisos de ubicación

Para utilizar el mapa con la posición actual y la navegación:

1. Activar la ubicación del dispositivo.
2. Autorizar a EcoRuta para acceder a la ubicación.
3. Mantener conexión a Internet para obtener el mapa y calcular recorridos.

La aplicación informa al usuario cuando el servicio de ubicación está desactivado o cuando los permisos han sido rechazados.

## Generar APK

### APK de prueba

```bash
flutter build apk --debug
```

Ruta habitual:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### APK release

```bash
flutter build apk --release
```

Ruta habitual:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Validación automática con GitHub Actions

Cada cambio enviado a la rama `main` activa el flujo de integración continua.

El proceso realiza:

```text
Checkout del repositorio
Configuración de Flutter estable
Generación de la plataforma Android
Generación del branding EcoRuta
Configuración de permisos Android
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
Publicación del APK como artefacto
```

Cuando la ejecución termina correctamente, GitHub Actions publica el artefacto:

```text
EcoRuta-0.4-debug-apk
```

Esto permite demostrar que el proyecto puede analizarse, probarse y compilarse automáticamente.

## Seguridad y buenas prácticas

EcoRuta utiliza reglas de seguridad de Cloud Firestore incluidas en:

```text
firestore.rules
```

Las reglas aplican controles como:

- Acceso únicamente para usuarios autenticados cuando corresponde.
- Favoritos restringidos al propietario.
- Rutas restringidas al propietario.
- Creación y modificación de destinos y categorías restringida al administrador.
- Consulta de auditoría restringida a Administrador y Auditor.
- Prohibición de modificar o eliminar registros de auditoría desde el cliente.
- Protección del rol del usuario para evitar que un usuario común se promueva a sí mismo.

Los archivos locales y credenciales sensibles deben mantenerse fuera del repositorio mediante `.gitignore`.

## Roles

El proyecto contempla los tres roles solicitados para la categoría Aficionado:

| Rol | Alcance actual |
|---|---|
| Usuario | Explorar destinos, guardar favoritos, crear y utilizar rutas |
| Administrador | Permisos de gestión de destinos y categorías; sincronización del catálogo desde la aplicación |
| Auditor | Permisos de lectura sobre usuarios autorizados y registros de auditoría definidos en las reglas de Firestore |

El control de acceso se realiza tanto desde la información del usuario como desde las reglas del backend.

## Identidad visual

EcoRuta utiliza una identidad visual inspirada en la naturaleza y biodiversidad de Nicaragua. El branding contempla un símbolo relacionado con el guardabarranco, paisajes naturales y una paleta basada principalmente en verdes, turquesa, tonos cálidos y fondos claros.

Los recursos de branding se generan durante la preparación del proyecto mediante:

```text
tool/generate_branding.py
```

## Pruebas

El proyecto incorpora pruebas automáticas que pueden ejecutarse con:

```bash
flutter test
```

También se recomienda validar en dispositivo físico:

- Inicio de sesión y registro.
- Persistencia de favoritos.
- Creación de rutas.
- Permisos de ubicación.
- Posición GPS.
- Cálculo y recálculo de recorridos.
- Visualización de marcadores y rutas en el mapa.

## Documentación adicional

```text
docs/base-de-datos.md
docs/interfaz-y-desarrollo.md
docs/estado-entregable-3.md
docs/firebase-configuracion.md
```

## Control de versiones

El proyecto utiliza Git y GitHub para registrar el avance y mantener un historial de cambios.

Comandos básicos:

```bash
git add .
git commit -m "descripcion del cambio"
git pull
git push
```

## Estado actual del proyecto

- README técnico: actualizado.
- Base de datos NoSQL y documentación: implementadas.
- Más de cinco pantallas funcionales: implementadas.
- Navegación principal: implementada.
- Formularios y autenticación: implementados.
- Firebase Authentication: integrado y probado.
- Cloud Firestore: integrado.
- Favoritos persistentes: implementados.
- Rutas persistentes: implementadas.
- Mapa interactivo: implementado.
- Ubicación GPS: implementada.
- Generación de recorridos con OSRM: implementada.
- Seguimiento de posición durante navegación: implementado.
- Recálculo de rutas: implementado.
- Identidad visual de EcoRuta: integrada.
- Reglas de seguridad por usuario y rol: implementadas.
- GitHub Actions: configurado.
- Compilación automática de APK: validada.

## Equipo

Proyecto desarrollado como trabajo colaborativo por un equipo de cinco integrantes.

## Licencia

Proyecto académico y de competencia desarrollado con fines educativos y de demostración.
