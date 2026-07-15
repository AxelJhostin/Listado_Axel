# Listado Axel

Aplicación móvil **offline-first** para comerciantes que gestionan compras de mercadería directamente en distribuidores. Reemplaza las listas de papel con una herramienta local, rápida y accesible.

## Características principales

- **100 % local**: sin conexión a internet en el mercado (Isar + archivos en disco).
- **Tres pestañas claras**: Compras, Catálogo y Distribuidores.
- **Flujo de Check**: registrar cantidad, precio y distribuidor al comprar un producto.
- **Fotos de productos**: cámara o galería, guardadas en almacenamiento interno.
- **UX accesible**: textos grandes, alto contraste, botones táctiles amplios (mín. 48×48 dp).

## Stack tecnológico

| Componente        | Tecnología                          |
|-------------------|-------------------------------------|
| Framework         | Flutter (Material 3)                |
| Base de datos     | Isar (NoSQL local)                  |
| Fotos             | `image_picker` + `path_provider`    |
| Arquitectura      | Feature-first                       |

## Estructura del proyecto

```
lib/
├── main.dart
├── database/isar_service.dart
├── models/
│   ├── distributor.dart
│   └── product.dart
├── theme/app_theme.dart
└── features/
    ├── shopping_list/
    ├── catalog/
    └── distributors/
```

## Diagrama Entidad-Relación (ERD)

Modelos de datos y relaciones Isar entre `Product` y `Distributor`.

```mermaid
erDiagram
    DISTRIBUTOR {
        int id PK "Isar autoIncrement"
        string name "Obligatorio, indexado"
        string locationNotes "Opcional — pasillo, local, dirección"
        string phoneNumber "Opcional"
    }

    PRODUCT {
        int id PK "Isar autoIncrement"
        string name "Obligatorio, indexado"
        int currentStock "Opcional — stock en tienda"
        string description "Opcional — notas cortas"
        string localImagePath "Opcional — ruta local de la foto"
        bool isChecked "Default false — ya comprado"
        int purchasedQuantity "Opcional — cantidad al marcar Check"
        double purchasePrice "Opcional — precio al marcar Check"
    }

    PRODUCT ||--o{ DISTRIBUTOR : "distributors (IsarLinks)"
    PRODUCT ||--o| DISTRIBUTOR : "finalDistributor (IsarLink)"
```

### Lógica de relaciones

| Relación            | Tipo Isar       | Cardinalidad | Descripción |
|---------------------|-----------------|--------------|-------------|
| `distributors`      | `IsarLinks`     | N : M        | Distribuidores donde **habitualmente** se consigue el producto. Se asignan al crear/editar en el Catálogo. |
| `finalDistributor`  | `IsarLink`      | N : 1        | Distribuidor donde se **compró finalmente** el producto. Se asigna al completar el Diálogo de Check. |

**Estados del producto según `isChecked`:**

- `isChecked == false` → aparece en la pestaña **Por Comprar**.
- `isChecked == true` → aparece en **Ya Comprados**, con `purchasedQuantity`, `purchasePrice` y `finalDistributor` poblados.

## Diagrama de flujo de usuario

Recorrido completo desde la pantalla principal hasta marcar un producto como comprado.

```mermaid
flowchart TD
    A[Inicio de la app] --> B[Pestaña Compras — Lista principal]
    B --> C{¿Hay productos por comprar?}
    C -- No --> D[Ir a Catálogo]
    D --> E[Tocar Nuevo producto]
    E --> F[Completar formulario]
    F --> F1[Nombre del producto]
    F --> F2[Stock en tienda opcional]
    F --> F3[Tomar foto o elegir de galería]
    F --> F4[Seleccionar distribuidores habituales]
    F --> G[Guardar producto en Isar]
    G --> H[Volver a pestaña Compras]
    H --> I[Producto visible en Por Comprar]

    C -- Sí --> I
    I --> J[Usuario toca botón Check verde]
    J --> K[Diálogo emergente de compra]
    K --> K1["¿Cuántos compraste? — stepper +/−"]
    K --> K2["¿A qué precio? — campo numérico"]
    K --> K3["¿Dónde lo compraste? — dropdown distribuidores"]
    K --> L{¿Datos completos?}
    L -- No --> K
    L -- Sí --> M[Guardar: isChecked = true]
    M --> N[Registrar cantidad, precio y finalDistributor]
    N --> O[Producto se mueve a Ya Comprados]
    O --> P[SnackBar de confirmación]

    B --> Q[Pestaña Distribuidores]
    Q --> R[Agregar proveedor con FAB +]
    R --> S[Nombre, ubicación y teléfono]
    S --> T[Distribuidor disponible en dropdown del Check]
```

## Cómo ejecutar

```bash
# Instalar dependencias
flutter pub get

# Generar código Isar (obligatorio tras cambiar modelos)
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en dispositivo o emulador
flutter run
```

### Regenerar modelos en desarrollo

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Criterios de accesibilidad aplicados

| Elemento              | Estándar aplicado                                      |
|-----------------------|--------------------------------------------------------|
| Texto de cuerpo       | 18 sp mínimo                                           |
| Etiquetas de campos   | 20 sp, negrita                                         |
| Títulos de sección    | 22–26 sp                                               |
| Botones principales   | Altura mínima 56 dp                                    |
| Botones +/− (Check)   | Área táctil mínima 48×48 dp                            |
| Contraste             | Verde oscuro (#0D5C2E) sobre fondo claro (#F8F9FA)     |
| Imágenes en tarjetas  | Contenedor fijo + `BoxFit.cover` (sin deformación)     |

## Próximos pasos sugeridos

- Deshacer compra (volver producto a Por Comprar).
- Búsqueda por nombre en lista y catálogo.
- Exportar resumen del día (PDF o compartir).
- Soporte `Semantics` para lectores de pantalla.

## Licencia

Proyecto privado — uso interno del comercio.
