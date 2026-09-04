# EcoRuta

## Descripción del proyecto

**EcoRuta** es una aplicación móvil orientada al turismo sostenible en Nicaragua. Su propósito es facilitar a los usuarios el descubrimiento de destinos turísticos, la consulta de información relevante de cada lugar, la exploración mediante mapas, la gestión de favoritos y la creación de rutas turísticas.

El proyecto está diseñado para centralizar información de destinos populares de Nicaragua en una experiencia móvil sencilla, accesible y organizada.

## Problema que busca resolver

Muchas personas que desean conocer destinos turísticos de Nicaragua encuentran la información distribuida en diferentes sitios, redes sociales y mapas. Esto dificulta comparar lugares, organizar recorridos y guardar sitios de interés.

EcoRuta busca reunir estas funciones dentro de una sola aplicación móvil.

## Objetivo general

Desarrollar una aplicación móvil que permita consultar, explorar y organizar destinos turísticos de Nicaragua mediante una interfaz amigable, información estructurada, mapas y rutas personalizadas.

## Objetivos específicos

- Mostrar destinos turísticos de Nicaragua de manera organizada.
- Permitir la búsqueda y filtrado de destinos.
- Mostrar información detallada de cada lugar.
- Integrar mapas y ubicación geográfica.
- Permitir guardar destinos como favoritos.
- Permitir crear y consultar rutas turísticas.
- Gestionar usuarios mediante autenticación.
- Implementar distintos roles y permisos dentro de la aplicación.
- Utilizar una base de datos NoSQL en la nube para almacenar la información.

## Funcionalidades principales

### Usuario

- Registro e inicio de sesión.
- Consulta de destinos turísticos.
- Búsqueda y exploración por categorías.
- Visualización de información detallada de cada destino.
- Consulta de ubicación en mapa.
- Gestión de destinos favoritos.
- Creación y consulta de rutas turísticas.
- Gestión básica de perfil.

### Administrador

- Acceso a funciones administrativas.
- Gestión de destinos turísticos.
- Gestión de categorías.
- Actualización del contenido disponible en la aplicación.
- Consulta de información relevante para la administración.

### Auditor

- Consulta de registros de actividad.
- Revisión de cambios realizados dentro del sistema.
- Acceso de solo lectura a información de auditoría.
- Sin permisos para modificar información administrativa.

## Roles del sistema

EcoRuta contempla tres roles principales:

| Rol | Permisos principales |
|---|---|
| Usuario | Explorar destinos, administrar favoritos, consultar mapas y crear rutas |
| Administrador | Gestionar destinos, categorías y contenido |
| Auditor | Consultar registros y cambios sin modificar información |

## Tecnologías utilizadas

### Aplicación móvil

- **Flutter**
- **Dart**

### Backend y servicios en la nube

- **Firebase Authentication** para autenticación de usuarios.
- **Cloud Firestore** como base de datos NoSQL.
- **Firebase Storage** para el almacenamiento de imágenes y recursos.
- **Firebase** como plataforma principal de servicios backend.

### Mapas y ubicación

- Integración de mapas compatible con Flutter.
- Servicios de geolocalización del dispositivo.

### Control de versiones

- **Git**
- **GitHub**

## Base de datos

EcoRuta utiliza **Cloud Firestore**, una base de datos NoSQL basada en documentos y colecciones.

La elección de Firestore permite una integración directa con Flutter y Firebase, facilita el almacenamiento flexible de información turística y permite trabajar con autenticación, datos e imágenes dentro del mismo ecosistema tecnológico.

### Colecciones principales

```text
usuarios/
destinos/
categorias/
favoritos/
rutas/
auditoria/
```

### Descripción de las colecciones

#### usuarios

Contiene la información básica de los usuarios registrados.

Ejemplo de campos:

```text
uid
nombre
correo
rol
fechaRegistro
activo
```

#### destinos

Contiene la información de los lugares turísticos disponibles en EcoRuta.

Ejemplo de campos:

```text
idDestino
nombre
descripcion
departamento
categoriaId
latitud
longitud
imagenUrl
activo
```

#### categorias

Permite organizar los destinos por tipo.

Ejemplo:

```text
Naturaleza
Playas
Cultura
Aventura
Historia
```

#### favoritos

Relaciona a un usuario con los destinos que ha guardado como favoritos.

Ejemplo de campos:

```text
usuarioId
destinoId
fechaAgregado
```

#### rutas

Almacena las rutas creadas por los usuarios.

Ejemplo de campos:

```text
idRuta
usuarioId
nombre
destinos
fechaCreacion
```

#### auditoria

Registra acciones importantes ejecutadas dentro del sistema.

Ejemplo de campos:

```text
usuarioId
accion
entidad
fecha
detalle
```

## Arquitectura general

EcoRuta utiliza una arquitectura móvil conectada a servicios Firebase.

```text
Usuario
   |
   v
Aplicación EcoRuta - Flutter
   |
   +-----------------------------+
   |                             |
   v                             v
Firebase Authentication     Cloud Firestore
   |                             |
   |                             +--> usuarios
   |                             +--> destinos
   |                             +--> categorias
   |                             +--> favoritos
   |                             +--> rutas
   |                             +--> auditoria
   |
   +---------------------------> Firebase Storage
                                  |
                                  +--> imágenes
```

## Flujo principal de navegación

```text
Inicio de la aplicación
        |
        v
Registro / Inicio de sesión
        |
        v
Pantalla principal
        |
        +--> Explorar destinos
        |
        +--> Buscar
        |
        +--> Categorías
        |
        +--> Mapa
        |
        +--> Favoritos
        |
        +--> Rutas
        |
        +--> Perfil
```

## Estructura general del proyecto

La estructura exacta puede variar durante el desarrollo, pero se mantiene una organización modular similar a la siguiente:

```text
lib/
|
+-- main.dart
|
+-- models/
|   +-- usuario.dart
|   +-- destino.dart
|   +-- categoria.dart
|   +-- ruta.dart
|
+-- screens/
|   +-- auth/
|   +-- home/
|   +-- destinos/
|   +-- mapa/
|   +-- rutas/
|   +-- perfil/
|   +-- admin/
|   +-- auditor/
|
+-- services/
|   +-- auth_service.dart
|   +-- firestore_service.dart
|   +-- storage_service.dart
|   +-- location_service.dart
|
+-- widgets/
|
+-- utils/
```

## Requisitos para ejecutar el proyecto

Antes de ejecutar EcoRuta se recomienda contar con:

- Flutter SDK instalado.
- Dart SDK incluido con Flutter.
- Android Studio o Visual Studio Code.
- Android SDK configurado.
- Un emulador Android o dispositivo físico.
- Proyecto Firebase configurado.
- Conexión a Internet para utilizar los servicios en la nube.

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/Lian-dev44/EcoRuta.git
```

### 2. Entrar a la carpeta del proyecto

```bash
cd EcoRuta
```

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Configurar Firebase

El proyecto debe contar con la configuración de Firebase correspondiente para Android.

Los archivos y parámetros de configuración deben asociarse al proyecto Firebase utilizado por EcoRuta.

### 5. Verificar el entorno

```bash
flutter doctor
```

### 6. Ejecutar la aplicación

```bash
flutter run
```

## Generación del APK

Para generar una versión APK de EcoRuta:

```bash
flutter build apk
```

El archivo generado normalmente se encontrará en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Buenas prácticas y seguridad

EcoRuta contempla las siguientes medidas:

- Autenticación mediante Firebase Authentication.
- Validación de datos antes de guardar información.
- Separación de permisos según roles.
- Restricción de funciones administrativas.
- Registro de acciones relevantes en auditoría.
- Manejo de errores durante operaciones con Firebase.
- Organización modular del código.
- Nombres descriptivos para clases, variables y métodos.
- Uso de Git y GitHub para control de versiones.

## Control de versiones

El proyecto utiliza Git como sistema de control de versiones y GitHub como repositorio remoto.

Comandos principales utilizados:

```bash
git add .
git commit -m "descripcion del cambio"
git push
git pull
```

Ejemplos de commits esperados:

```text
Initial commit: estructura base de EcoRuta
feat: agregar autenticacion de usuarios
feat: implementar pantalla principal
feat: agregar listado de destinos
feat: integrar mapa y ubicacion
feat: implementar favoritos
feat: agregar gestion de rutas
feat: implementar roles y permisos
docs: agregar documentacion tecnica
fix: corregir validaciones y navegacion
```

## Ejecución de la solución

EcoRuta está diseñada para ejecutarse de forma local durante el desarrollo mediante Flutter y para instalarse en dispositivos Android utilizando un archivo APK.

La demostración final debe incluir un recorrido por las principales pantallas y funcionalidades de la aplicación.

## Estado del proyecto

Proyecto en desarrollo para la fase de preclasificación del **Hackathon Nicaragua 2026**, categoría **Aficionado**.

## Equipo

Proyecto desarrollado como trabajo colaborativo de un equipo de cuatro integrantes.

## Licencia

Proyecto académico y de competencia desarrollado con fines educativos y de demostración.
