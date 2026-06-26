# Android App Bundle Guide

## Generating a Keystore

1. Run the following command to generate a keystore:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Move the generated `upload-keystore.jks` file to the `android/app/` directory.

3. Create a `key.properties` file in the `android` directory using the template `key.properties.template` and fill in the correct values.

## Building the App Bundle

To generate an Android App Bundle (.aab file), run:

```bash
flutter build appbundle
```

The output file will be located at:
`build/app/outputs/bundle/release/app-release.aab`

## Environment Variables (Alternative to key.properties)

Alternatively, you can set environment variables for CI/CD pipelines:

```bash
export KEYSTORE_PATH="path/to/your/upload-keystore.jks"
export KEYSTORE_PASSWORD="your_keystore_password"
export KEY_ALIAS="upload"
export KEY_PASSWORD="your_key_password"
```

## Important Notes

- Keep your keystore file and passwords secure. If you lose them, you won't be able to update your app on Google Play.
- Back up your keystore file in a secure location.
- Never commit the keystore or key.properties file to version control.
