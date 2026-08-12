# Android release signing

The project supports two signing methods:

1. Local build: `android/key.properties` + `android/keystore/ShiYe-Android-Release.jks`.
2. CI build: environment variables override local properties:
   - `ANDROID_KEYSTORE_PATH`
   - `ANDROID_KEYSTORE_PASSWORD`
   - `ANDROID_KEY_ALIAS`
   - `ANDROID_KEY_PASSWORD`

`key.properties`, `*.jks`, and the `android/keystore/` directory are git-ignored. Do not commit signing secrets to a public repository.
