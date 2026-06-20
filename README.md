# Proyecto - Sistema de Gestión de Imprenta

Aplicación Flutter para gestión integral de operaciones de imprenta con autenticación basada en Firebase, control de inventario, gestión de trabajadores y órdenes de producción.

## Descripción General

Sistema completo de gestión empresarial con:
- Autenticación y control de acceso por roles
- Gestión de trabajadores y perfiles
- Órdenes de producción
- Control de inventario (insumos, bodega y proveedores)
- Registro de asistencia con marcaje de entrada/salida
- Notificaciones internas en tiempo real
- Auditoría y seguridad (bloqueos por intentos fallidos)

---

## Librerías y Dependencias

### Dependencias Principales

| Librería | Versión | Propósito |
|----------|---------|----------|
| `flutter` | SDK | Framework base |
| `firebase_core` | ^4.9.0 | Inicialización de Firebase |
| `firebase_auth` | ^6.5.1 | Autenticación y gestión de usuarios |
| `cloud_firestore` | ^6.4.1 | Base de datos NoSQL en tiempo real |
| `provider` | ^6.1.5+1 | Gestión de estado (ViewModel pattern) |
| `cupertino_icons` | ^1.0.8 | Iconografía iOS |
| `intl` | ^0.20.2 | Internacionalización y formateo de datos |
| `shared_preferences` | ^2.5.5 | Almacenamiento local de preferencias |
| `rut_validator` | *local* | Validación de RUT (paquete local) |

### Dependencias de Desarrollo

| Librería | Versión | Propósito |
|----------|---------|----------|
| `flutter_test` | SDK | Framework de testing |
| `flutter_lints` | ^6.0.0 | Análisis estático de código |

### Entorno Requerido

```yaml
SDK de Dart: ^3.11.1
SDK de Flutter: Última versión estable recomendada
```

---

## Requisitos del Sistema

- **Flutter SDK**: >= 3.5.0
- **Dart SDK**: >= 3.11.1
- **Android**: Mínimo API 21
- **Web**: Chrome, Firefox, Safari, Edge (con Firebase habilitado)
- **Acceso a Internet**: Requerido para conectar con Firebase

---

## Backend - Firebase

### Descripción

El backend utiliza **Firebase** como servicio principal, específicamente:

- **Firebase Authentication**: Gestión de usuarios y sesiones
- **Cloud Firestore**: Base de datos en tiempo real

### Proyecto Firebase

```
Nombre del Proyecto: imprenta-asistencia
Project ID: imprenta-asistencia
```

### Credenciales Web

```
API Key: AIzaSyDNwuGZGIzeKQl0vYIkbumB5jNA3Pt--a0
Auth Domain: imprenta-asistencia.firebaseapp.com
Project ID: imprenta-asistencia
Storage Bucket: imprenta-asistencia.firebasestorage.app
Messaging Sender ID: 1044116654048
App ID (Web): 1:1044116654048:android:8a7d192783f831c7fc8d85
```

### Colecciones de Firestore

| Colección | Descripción |
|-----------|-------------|
| `users` | Información de usuarios autenticados |
| `trabajadores` | Perfil de trabajadores con cargo y rol |
| `ordenes_trabajo` | Órdenes de producción |
| `insumos` | Catálogo de insumos/materiales |
| `movimiento_bodega` | Historial de entradas/salidas de inventario |
| `proveedores` | Información de proveedores |
| `asistencia` | Registros de asistencia |
| `notificaciones_internas` | Notificaciones del sistema |
| `bloqueos_seguridad` | Control de intentos fallidos y bloqueos |
| `auditorias` | Registros de auditoría |

### Cómo Conectarse a Firebase

#### **Opción 1: Configuración Automática (Android/iOS)**

```bash
# Instalar CLI de Firebase
npm install -g firebase-tools

# Conectarse a la cuenta de Firebase
firebase login

# Configurar el proyecto automáticamente
flutterfire configure --project=imprenta-asistencia
```

#### **Opción 2: Configuración Manual (Android/Web)**

1. **Descargar configuraciones:**
   - Para Android: `google-services.json` → `android/app/`
   - Para Web: Ya está configurado en `lib/main.dart`

### Reglas de Seguridad (Firestore)

Las reglas deben configurarse en la consola de Firebase para:

- Validar autenticación del usuario
- Validar rol y cargo del usuario
- Controlar acceso a colecciones específicas
- Auditar cambios

**Consola Firebase**: [https://console.firebase.google.com/project/imprenta-asistencia](https://console.firebase.google.com/project/imprenta-asistencia)

---

## Configuración Inicial

### 1. Clonar el repositorio

```bash
git clone https://github.com/Mikrr0/Imprenta.git
cd proyecto
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase (si no está configurado)

```bash
flutterfire configure --project=imprenta-asistencia
```

### 4. Ejecutar la aplicación

```bash
# En dispositivo Android o emulador
flutter run

# En navegador web
flutter run -d chrome
```

### 5. Compilar para Producción

```bash
# APK para Android
flutter build apk --release
# Ubicación: build/app/outputs/flutter-apk/app-release.apk (50.7 MB)

# Versión Web
flutter build web --release --base-href "./"
# Ubicación: build/web/
```

### Credenciales de Prueba

Solicitar credenciales al administrador del sistema para:
- **Operario de Impresión** (Rol: Operario)
- **Jefe de Taller** (Rol: Jefe)
- **Administrador** (Rol: Administrador - Acceso total)

---

## Estructura del Proyecto

```
lib/
├── main.dart                          # Entrada y configuración de Firebase
├── core/
│   ├── constants/
│   │   ├── app_config.dart           # Configuración: roles, cargos, permisos
│   │   └── app_colors.dart           # Paleta de colores
│   ├── services/
│   │   ├── security_service.dart     # Seguridad: bloqueos y validaciones
│   │   ├── audit_service.dart        # Auditoría de cambios
│   │   ├── notificacion_service.dart # Notificaciones internas
│   │   ├── logging_service.dart      # Registro de logs
│   │   └── orden_trabajo_service.dart # Lógica de órdenes
│   ├── models/                        # Modelos de datos
│   ├── theme/                         # Temas (claro/oscuro)
│   ├── validators/                    # Validadores de entrada
│   ├── guards/                        # Guards de protección de rutas
│   └── injection.dart                 # Inyección de dependencias
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── home_page.dart
│   │   │   │   ├── personal_list_page.dart
│   │   │   │   ├── my_profile_page.dart
│   │   │   │   └── recuperar_clave_page.dart
│   │   │   └── viewmodels/
│   │   │       ├── login_viewmodel.dart
│   │   │       ├── personal_viewmodel.dart
│   │   │       └── asistencia_viewmodel.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   ├── usecases/
│   │   │   └── entities/
│   │   └── data/
│   │       ├── datasources/
│   │       └── repositories/
│   ├── orden_trabajo/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   ├── insumos/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   ├── bodega/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   └── notificaciones/
│       ├── presentation/
│       ├── domain/
│       └── data/
├── assets/
│   └── images/
│       └── logo_fuentes.jfif
└── rut_validator/                     # Paquete local de validación RUT
```

---

## Módulos Principales

### **1. Autenticación (Auth)**
- Login con RUT y contraseña
- Validación de intentos fallidos (máx 5, bloqueo 15 min)
- Recuperación de contraseña
- Gestión de sesiones locales y Firebase
- Roles: Operario, Jefe, Administrador

### **2. Gestión de Trabajadores**
- CRUD de perfiles de trabajadores
- Asignación de cargos y roles
- Validación de combinación cargo-rol
- Auditoría de cambios

### **3. Órdenes de Trabajo**
- Crear, editar y visualizar órdenes
- Asignación a operarios
- Estado: Pendiente, En Progreso, Completado
- Seguimiento en tiempo real

### **4. Gestión de Inventario**
- Catálogo de insumos
- Control de bodega (entradas/salidas)
- Gestión de proveedores
- Movimientos con auditoría

### **5. Asistencia y Control de Horario**
- Marcaje de entrada/salida
- Historial de asistencia
- Control con timeout entre marcajes
- Integración con Firebase

### **6. Notificaciones**
- Sistema de notificaciones internas
- Historial de notificaciones por rol
- Contador de notificaciones sin leer

### **7. Seguridad y Auditoría**
- Control de acceso por rol y cargo
- Bloqueo automático tras intentos fallidos
- Registro de todas las acciones
- Validación de permisos en UI y API

---

## Control de Acceso (RBAC)

### Roles del Sistema

| Rol | Descripción | Acceso |
|-----|-------------|--------|
| **Operario** | Personal operativo | Ver tareas asignadas, marcar asistencia |
| **Jefe** | Supervisión de área | Crear órdenes, supervisar inventario |
| **Administrador** | Acceso total | Gestión de todo, auditoría, reportes |

### Cargos Permitidos

```
Operario: Operario de Impresión, Operario de Corte
Jefe: Jefe de Taller, Encargado de Bodega
Administrador: Administrador, Gerente
```
