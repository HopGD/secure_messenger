# Secure Messenger

> Comunicación privada y cifrada sin dependencias de plataforma.

Secure Messenger es una aplicación de mensajería segura que prioriza tu privacidad. Utiliza cifrado RSA para garantizar que solo tú y tu destinatario puedan leer los mensajes, sin importar qué medio de comunicación uses.

## Características

- **Cifrado RSA de extremo a extremo**: Tus mensajes solo pueden ser leídos por quien les corresponde
- **Gestor de claves integrado**: Genera, almacena y gestiona tus pares de claves pública/privada
- **Independiente del medio**: Envía mensajes cifrados por cualquier canal (email, SMS, WhatsApp, Telegram...)
- **Código abierto**: Puedes auditar y verificar la seguridad del código
- **Sin servidores**: No hay terceros involucrados en tu comunicación

## Cómo funciona

1. **Genera tus claves**: Crea un par de claves RSA únicas para ti
2. **Comparte tu clave pública**: Envía tu clave pública a quien quieras que te envíe mensajes seguros
3. **Envía mensajes cifrados**: Usa la clave pública del destinatario para cifrar mensajes
4. **Descifra mensajes recibidos**: Solo tu clave privada puede descifrar mensajes dirigidos a ti

## Instalación

```bash
flutter pub get
flutter run
```

## Estructura del proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── models/
│   └── rsa_key_model.dart    # Modelo de datos para claves RSA
├── providers/
│   └── crypto_provider.dart  # Lógica de cifrado/descifrado
└── screens/
    ├── home_screen.dart      # Pantalla principal
    └── key_manager_screen.dart  # Gestión de claves
```

## Seguridad

- **Clave privada**: Nunca se comparte y se almacena localmente
- **Clave pública**: Diseñada para compartir libremente
- **Cifrado robusto**: RSA con longitudes de clave estándar

## Contribuir

Las contribuciones son bienvenidas. Por favor, abre un issue para sugerencias o mejoras.

## Licencia

MIT License
