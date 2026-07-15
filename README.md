# Listado Axel

Aplicación móvil **offline-first** para comerciantes que gestionan compras de mercadería directamente en distribuidores. Reemplaza las listas de papel con una herramienta local, rápida y accesible.

## Características principales

- **100 % local**: sin conexión a internet en el mercado (Isar + archivos en disco).
- **Tres pestañas claras**: Compras, Catálogo y Distribuidores.
- **Flujo de Check**: registrar cantidad, precio y distribuidor al comprar un producto.
- Búsqueda en tiempo real: filtra productos por nombre en Compras y en el Catálogo.
- **Deshacer compra**: revierte un producto de Ya Comprados a Por Comprar.
- **Banner de resumen del día**: total de unidades y dinero invertido, actualizado en vivo.
- **Compartir resumen**: exporta el reporte del día por WhatsApp, Telegram, correo o notas.
- **Fotos de productos**: cámara o galería, guardadas en almacenamiento interno.
- **UX accesible**: textos grandes, alto contraste, botones táctiles amplios (mín. 48×48 dp).

## Stack tecnológico

| Componente        | Tecnología                          |
|-------------------|-------------------------------------|
| Framework         | Flutter (Material 3)                |
| Base de datos     | Isar (NoSQL local)                  |
| Fotos             | `image_picker` + `path_provider`    |
| Compartir         | `share_plus`                        |
| Arquitectura      | Feature-first                       |

## Estructura del proyecto

```
lib/
├── main.dart
├── widgets/product_search_bar.dart
├── database/isar_service.dart
├── models/
│   ├── distributor.dart
│   └── product.dart
├── theme/app_theme.dart
└── features/
    ├── shopping_list/
    │   ├── utils/purchase_report_builder.dart
    │   └── widgets/
    ├── catalog/
    └── distributors/
```

## Funcionalidades de la Lista de Compras

| Función              | Descripción |
|----------------------|-------------|
| Búsqueda (Compras)   | Barra superior que filtra por nombre en **Por Comprar** y **Ya Comprados**. |
| Búsqueda (Catálogo) | Barra superior que filtra el inventario general por nombre en tiempo real. |
| Check de compra      | Diálogo con cantidad (+/−), precio y distribuidor. |
| Deshacer             | Botón en tarjetas de Ya Comprados; limpia datos de compra y restaura `isChecked = false`. |
| Banner resumen       | Muestra unidades totales y monto invertido (Σ cantidad × precio). |
| Compartir            | Botón en AppBar (pestaña Ya Comprados) genera reporte en texto plano y abre el share nativo. |

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

Recorrido completo desde la pantalla principal hasta compartir el resumen del día.

```mermaid
flowchart TD
    A[Inicio de la app] --> B[Pestaña Compras — Lista principal]
    B --> B1[Barra de búsqueda por nombre]
    B1 --> C{¿Hay productos por comprar?}
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
    O --> P[Banner de resumen se actualiza]
    P --> Q[SnackBar de confirmación]

    B --> R[Pestaña Ya Comprados]
    R --> R1[Banner: unidades y total invertido]
    R --> R2{¿Se equivocó al registrar?}
    R2 -- Sí --> R3[Botón Deshacer en tarjeta]
    R3 --> R4[Confirmar y resetPurchase en Isar]
    R4 --> R5[Producto vuelve a Por Comprar]
    R2 -- No --> R6[Botón Compartir en AppBar]
    R6 --> R7[Generar reporte en texto plano]
    R7 --> R8[Share nativo: WhatsApp, Telegram, correo, notas]

    B --> S[Pestaña Distribuidores]
    S --> T[Agregar proveedor con FAB +]
    T --> U[Nombre, ubicación y teléfono]
    U --> V[Distribuidor disponible en dropdown del Check]
```

## Formato del reporte compartido

Ejemplo generado dinámicamente por `PurchaseReportBuilder`:

```
🛒 *Resumen de Compra - 15 julio 2026*
💰 *Total Invertido:* $125.50 (18 unidades)
----------------------------------
* Arroz 1kg
  - Cantidad: 10 unidades
  - Precio unitario: $8.50
  - Subtotal: $85.00
  - Proveedor: Distribuidora El Centro

* Aceite 900ml
  - Cantidad: 8 unidades
  - Precio unitario: $5.06
  - Subtotal: $40.50
  - Proveedor: Mayorista Norte
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
| Botón compartir       | Área táctil mínima 48×48 dp en AppBar                  |
| Contraste             | Verde oscuro (#0D5C2E) sobre fondo claro (#F8F9FA)     |
| Imágenes en tarjetas  | Contenedor fijo + `BoxFit.cover` (sin deformación)     |

## Próximos pasos sugeridos

- Filtro por distribuidor en la lista de compras.
- Exportar resumen a PDF.
- Soporte `Semantics` ampliado para lectores de pantalla.

## Licencia

Proyecto privado — uso interno del comercio.
