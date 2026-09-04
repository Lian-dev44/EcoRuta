# Interfaz y desarrollo — EcoRuta

## Objetivo del entregable

Implementar en Flutter una interfaz móvil navegable con al menos cinco pantallas funcionales, navegación fluida, coherencia estética, formularios e interacciones demostrables.

## Estado actual del MVP

La primera implementación funcional incluye **7 pantallas/áreas**:

1. **Inicio de sesión**: formulario con validación de correo y contraseña.
2. **Inicio**: bienvenida, categorías y destinos destacados.
3. **Explorar**: búsqueda por texto, filtro por categoría y acceso al detalle.
4. **Detalle del destino**: información del lugar, guardar/quitar favorito y acceso preparado para mapa.
5. **Favoritos**: lista dinámica de destinos guardados.
6. **Rutas**: formulario para crear una ruta y seleccionar varios destinos.
7. **Perfil**: datos básicos del usuario y cierre de sesión.

## Navegación

La navegación principal utiliza una barra inferior con cinco secciones:

- Inicio
- Explorar
- Favoritos
- Rutas
- Perfil

El detalle de un destino se abre mediante navegación secundaria desde Inicio, Explorar o Favoritos.

## Interacciones funcionales

- Validación del formulario de inicio de sesión.
- Búsqueda de destinos.
- Filtro por categorías.
- Apertura del detalle de un destino.
- Agregar y quitar favoritos.
- Crear rutas seleccionando uno o más destinos.
- Cerrar sesión.

## Coherencia estética

La interfaz usa Material 3 y una identidad visual basada en tonos verdes para reforzar el concepto de turismo sostenible. Se mantienen bordes redondeados, tarjetas, espaciado uniforme, iconografía consistente y jerarquía tipográfica.

## Backend

Esta versión inicial funciona en **modo demostración local** para asegurar que todas las pantallas e interacciones puedan probarse sin depender todavía de configuración externa. La siguiente integración conecta estas mismas operaciones con Firebase Authentication y Cloud Firestore, manteniendo la estructura definida en `docs/base-de-datos.md`.

## Evidencia recomendada

Para la entrega se deben capturar, como mínimo:

- Pantalla de inicio de sesión.
- Inicio.
- Explorar con búsqueda o filtro activo.
- Detalle de un destino.
- Favoritos.
- Formulario de creación de ruta.
- Ruta creada.
- Perfil.

La demostración en video debe mostrar la navegación entre pantallas y al menos una interacción completa: iniciar sesión, buscar un destino, guardarlo como favorito y crear una ruta.
