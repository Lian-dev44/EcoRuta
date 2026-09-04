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
- [x] Pruebas de navegación por las cinco secciones principales.
- [x] Prueba automática de creación de rutas desde la interfaz.
- [x] APK de depuración compilado correctamente en GitHub Actions.
- [x] APK publicado como artefacto de GitHub Actions.
- [x] Reglas base de seguridad de Firestore incluidas en el repositorio.
- [ ] Validación final en un dispositivo con el proyecto Firebase real de EcoRuta.

## Pantallas implementadas

1. Inicio de sesión.
2. Registro.
3. Inicio.
4. Explorar.
5. Detalle del destino.
6. Favoritos.
7. Rutas.
8. Crear ruta.
9. Perfil.

## Navegación principal

```text
Inicio | Explorar | Favoritos | Rutas | Perfil
```

Se utiliza `IndexedStack` para conservar el estado de las pestañas principales y `Navigator` para las pantallas secundarias.

## Validación automática comprobada

La ejecución **Flutter CI #10** finalizó correctamente sobre el commit:

```text
aefe777c382c31e2317119d4676f5de50a84c0b9
```

El flujo completó satisfactoriamente:

1. Checkout del repositorio.
2. Instalación de Flutter estable.
3. Generación de la plataforma Android para la compilación.
4. Instalación de dependencias.
5. `flutter analyze`.
6. `flutter test`.
7. `flutter build apk --debug`.
8. Publicación del APK como artefacto.

El artefacto generado se llama:

```text
EcoRuta-debug-apk
```

Esta ejecución valida que la aplicación puede analizarse, probarse y compilarse como APK Android sin errores.

## Backend implementado

Cuando se suministra la configuración del proyecto Firebase, las siguientes operaciones utilizan backend real:

| Función | Backend |
|---|---|
| Registro | Firebase Authentication + `usuarios` |
| Inicio de sesión | Firebase Authentication |
| Restauración de sesión | Firebase Authentication |
| Lectura de destinos | `destinos` |
| Guardar/quitar favoritos | `favoritos` |
| Crear y consultar rutas | `rutas` |

La aplicación muestra de forma visible si está ejecutándose con:

```text
Firebase conectado
```

o con:

```text
Modo demostración local
```

## Experiencia de usuario incorporada

- Validación de formularios.
- Indicadores de carga.
- Mensajes de error con `SnackBar`.
- Estados vacíos explicativos.
- Búsqueda por texto.
- Filtros por categoría.
- Conservación del estado entre pestañas.
- Botones deshabilitados durante operaciones asíncronas.
- Actualización mediante `RefreshIndicator`.
- Confirmación visual inmediata de favoritos y rutas.
- Identidad gráfica consistente en Material 3.

## Prueba final requerida con Firebase real

Para cerrar completamente la validación externa del backend debe ejecutarse la aplicación con el proyecto Firebase real de EcoRuta y comprobar:

1. Crear una cuenta.
2. Confirmar el usuario en Firebase Authentication.
3. Confirmar el perfil en `usuarios/{uid}`.
4. Leer destinos desde Firestore.
5. Guardar un favorito y comprobar `favoritos`.
6. Quitar el favorito y comprobar su eliminación.
7. Crear una ruta y comprobar `rutas`.
8. Cerrar y volver a abrir la app para verificar persistencia.

La configuración necesaria está documentada en:

```text
docs/firebase-configuracion.md
```

## Evidencias recomendadas para la entrega

1. Captura de la pantalla de inicio de sesión.
2. Captura de la pantalla Inicio.
3. Captura de Explorar con búsqueda o filtro aplicado.
4. Captura del detalle de un destino.
5. Captura de Favoritos.
6. Captura del formulario Crear ruta.
7. Captura de una ruta creada.
8. Captura de Perfil mostrando `Firebase conectado`.
9. Captura de Firebase Authentication con el usuario de prueba.
10. Captura de Firestore mostrando `usuarios`, `destinos`, `favoritos` y `rutas`.
11. Captura de GitHub Actions con una ejecución exitosa.
