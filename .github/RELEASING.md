# Android releases

The `Android Release` workflow runs when a version tag such as `v1.2.0` is pushed. It checks formatting, analyzes the Dart code, runs tests, builds a signed release APK, and attaches it to a GitHub Release.

## One-time signing setup

Android only accepts an in-place update when the new APK is signed with the same signing key as the installed release. Keep this key safe and reuse it for every release.

1. Create an upload keystore locally and keep it outside the repository:

   ```powershell
   keytool -genkeypair -v -keystore sudoku-upload-key.jks -alias sudoku-upload -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Convert the keystore to Base64 in PowerShell and copy it directly to the clipboard:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes(".\sudoku-upload-key.jks")) | Set-Clipboard
   ```

3. In the GitHub repository, open **Settings → Secrets and variables → Actions** and create these repository secrets:
   - `ANDROID_KEYSTORE_BASE64`: the Base64 clipboard contents
   - `ANDROID_KEYSTORE_PASSWORD`: the keystore password
   - `ANDROID_KEY_ALIAS`: `sudoku-upload` (or the alias you chose)
   - `ANDROID_KEY_PASSWORD`: the key password

Never commit the keystore, passwords, or Base64 value. Keep a secure backup of the keystore; losing it prevents future APKs from updating installations signed with it.

## Publishing a release

After the signing secrets are configured and the changes are merged into `main`, create and push a version tag:

```powershell
git switch main
git pull
git tag v1.2.0
git push origin v1.2.0
```

Use the next version number rather than copying `v1.2.0` literally. The workflow creates a GitHub Release and uploads `sudoku-app-vX.Y.Z.apk`.

The CI workflow runs on pull requests and relevant branch pushes. It checks Dart formatting, runs `flutter analyze` and `flutter test`, and verifies that a debug APK can be built.
