# Fast Delivery

Flutter/Firebase multi-app delivery system.

## Project Structure

```
fast-delivery/
├── apps/
│   ├── customer_app/   - Customer mobile app
│   ├── rider_app/       - Delivery rider mobile app
│   ├── seller_app/      - Restaurant seller mobile app
│   └── admin_panel/    - Admin web dashboard
├── packages/
│   └── common/         - Shared code package
├── assets/
│   └── keys/          - Firebase service accounts
└── AGENTS.md          - Project configuration
```

## Architecture

- **Pattern**: Clean Architecture + MVVM
- **State Management**: Riverpod
- **Networking**: Dio
- **Models**: Freezed
- **Backend**: Firebase (Auth, Firestore, Cloud Functions, FCM)

## Getting Started

1. Install dependencies per app:
   ```bash
   cd apps/customer_app && flutter pub get
   cd apps/rider_app && flutter pub get
   cd apps/seller_app && flutter pub get
   cd apps/admin_panel && flutter pub get
   ```

2. Run an app:
   ```bash
   cd apps/customer_app && flutter run
   ```

## Apps

| App | Platform | Description |
|-----|----------|-------------|
| customer_app | iOS/Android | Customer ordering |
| rider_app | iOS/Android | Delivery driver |
| seller_app | iOS/Android | Restaurant management |
| admin_panel | Web | Admin dashboard |

## Roles

- **customer**: Customer placing orders
- **rider**: Delivery driver
- **seller**: Restaurant owner
- **admin**: System administrator