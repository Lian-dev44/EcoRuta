# Interfaz y desarrollo — EcoRuta

## Objetivo del entregable

Cumplir el requisito de preclasificación:

> Implementación en código de la interfaz gráfica con al menos cinco pantallas funcionales. Debe incluir navegación fluida, coherencia estética, interacción con el backend (cuando aplique) y reflejar una experiencia de usuario sólida.

## Implementación actual

EcoRuta cuenta con más de cinco pantallas funcionales:

1. **Inicio de sesión**
   - Formulario con validación.
   - Inicio de sesión con Firebase Authentication cuando Firebase está configurado.

2. **Registro**
   - Nombre, correo, contraseña y confirmación.
   - Creación de usuario en Firebase Authentication.
   - Creación de perfil en `usuarios`.

3. **Inicio**
   - Bienvenida personalizada.
   - Estado del backend.
   - Destinos destacados.
   - Acceso al detalle y favoritos.

4. **Explorar**
   - Búsqueda por destino, municipio o departamento.
   - Filtro por categoría.
   - Acceso al detalle de cada destino.

5. **Detalle del destino**
   - Descripción.
   - Departamento, municipio y coordenadas.
   - Guardar o quitar favorito.

6. **Favoritos**
   - Lista dinámica.
   - Persistencia en la colección `favoritos` cuando Firebase está activo.

7. **Rutas**
   - Listado de rutas creadas.
   - Persistencia en Firestore.

8. **Crear ruta**
   - Formulario validado.
   - Selección de dos o más destinos.
   - Guardado en `rutas`.

9. **Perfil**
   - Datos del usuario.
   - Rol.
   - Estado del backend.
   - Contadores.
   - Cierre de sesión.
   - Carga inicial de destinos en Firestore si la colección está vacía.

## Navegación

La navegación principal utiliza una barra inferior:

```text
Inicio | Explorar | Favoritos | Rutas | Perfil
```

La aplicación usa navegación secundaria para:

- Abrir el detalle de un destino.
- Abrir el formulario de registro.
- Abrir el formulario de creación de rutas.

Se utiliza `IndexedStack` en la navegación principal para conservar el estado de cada pestaña y `Navigator` para pantallas secundarias.

## Coherencia estética

La interfaz utiliza Material 3 y una identidad visual consistente:

- Verde como color principal.
- Fondos claros.
- Tarjetas blancas.
- Bordes redondeados.
- Iconografía consistente.
- Jerarquía tipográfica.
- Mensajes de estado vacío.
- Indicadores de carga.
- Mensajes de error mediante `SnackBar`.
- `RefreshIndicator` para actualizar datos.

## Interacción con backend

Cuando se suministra la configuración de Firebase, EcoRuta utiliza backend real:

| Función | Servicio / colección |
|---|---|
| Registro | Firebase Authentication |
| Inicio de sesión | Firebase Authentication |
| Perfil | `usuarios` |
| Listado de destinos | `destinos` |
| Favoritos | `favoritos` |
| Rutas | `rutas` |
| Cerrar sesión | Firebase Authentication |

Si Firebase no está configurado, la app activa automáticamente un modo demostración local para evitar que la interfaz deje de funcionar durante desarrollo.

## Persistencia demostrable

Con Firebase activo se puede demostrar:

1. Crear una cuenta.
2. Cargar destinos desde Firestore.
3. Guardar un favorito.
4. Cerrar y volver a abrir la aplicación.
5. Iniciar sesión nuevamente.
6. Comprobar que el favorito continúa guardado.
7. Crear una ruta.
8. Comprobar el documento en Firestore.

## Experiencia de usuario

La interfaz incorpora:

- Validaciones antes de enviar formularios.
- Estados vacíos comprensibles.
- Estados de carga.
- Mensajes de error.
- Retroalimentación al guardar información.
- Persistencia de pestañas principales.
- Búsqueda y filtros.
- Botones deshabilitados durante operaciones.
- Acciones claramente identificadas.

## Evidencia recomendada para el jurado

Capturas mínimas:

1. Inicio de sesión mostrando `Firebase conectado`.
2. Registro de usuario.
3. Inicio con destinos cargados.
4. Exploración con filtro activo.
5. Detalle de destino.
6. Favorito guardado.
7. Creación de una ruta.
8. Ruta creada.
9. Perfil.
10. Firebase Console mostrando `usuarios`, `favoritos` y `rutas`.

## Video recomendado

Recorrido de 2 a 4 minutos:

1. Abrir EcoRuta.
2. Iniciar sesión.
3. Mostrar Inicio.
4. Explorar y filtrar.
5. Abrir un destino.
6. Guardarlo como favorito.
7. Ver Favoritos.
8. Crear una ruta con dos destinos.
9. Volver a Rutas.
10. Mostrar Perfil y el indicador `Firebase conectado`.
