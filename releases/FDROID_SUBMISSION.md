# F-Droid Submission Template for Secure Messenger

## App Information

| Field | Value |
|-------|-------|
| **App Name** | Secure Messenger |
| **Package ID** | com.secure.messenger |
| **Description** | A secure messaging app with asymmetric encryption (RSA) |
| **License** | GPL-3.0-or-later |
| **Category** | Communication |
| **Website** | https://github.com/HopGD/secure_messenger |
| **Source Code** | https://github.com/HopGD/secure_messenger |
| **Issue Tracker** | https://github.com/HopGD/secure_messenger/issues |
| **Changelog** | https://github.com/HopGD/secure_messenger/releases |
| **Version Name** | 1.0.0 |
| **Version Code** | 1 |

## Description

Secure Messenger is an encrypted messaging application that uses asymmetric RSA encryption to protect your communications. Features include:

- **Generate Key Pairs**: Create your own private/public RSA key pairs
- **Import Contacts**: Add public keys of your contacts
- **Encrypt Messages**: Encrypt messages using recipient's public key
- **Decrypt Messages**: Decrypt messages using your private key
- **Secure Storage**: Private keys are stored securely on device
- **Key Management**: Edit, delete, and regenerate keys as needed

### Encryption Details

- Algorithm: RSA 2048 bits
- Padding: PKCS1v15
- Keys are never transmitted - all encryption happens locally

## Required Permissions

- `INTERNET` - Required for F-Droid linking (no network usage in app)
- No other special permissions required

## Build Information

### Build System

- **Build System**: Flutter
- **SDK Version**: >=3.0.0 <4.0.0

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  fast_rsa: ^3.0.1
  flutter_secure_storage: ^9.2.4
  crypto: ^3.0.3
```

### Anti-Features

- **No Anti-Features** - This app has no ads, tracking, or analytics
- No internet permission required (can be removed from AndroidManifest.xml)


## Signing

- The app is currently unsigned
- For F-Droid, the repo will re-sign with their own key

## Additional Notes

- This app is fully open source
- No binary blobs or proprietary components
- Reproducible builds are supported
- All cryptographic operations are performed locally on the device

## Submission Checklist

- [x] App has a valid free license (GPL-3.0+)
- [x] Source code is publicly accessible
- [x] App complies with F-Droid Anti-Features policy
- [x] No proprietary libraries or SDKs
- [x] Dependencies are compatible with GPL

## Categories Allowed

- Communication
- Security

## Suggestion

This app can be submitted via F-Droid's issue tracker:
https://gitlab.com/fdroid/fdroiddata/-/issues

Or by creating a pull request to the fdroiddata repository.
