from pathlib import Path

manifest = Path('android/app/src/main/AndroidManifest.xml')
if not manifest.exists():
    raise SystemExit('No se encontró AndroidManifest.xml. Ejecuta flutter create primero.')

text = manifest.read_text(encoding='utf-8')
permissions = [
    '<uses-permission android:name="android.permission.INTERNET" />',
    '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />',
    '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />',
]

missing = [permission for permission in permissions if permission not in text]
if missing:
    marker = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
    if marker not in text:
        raise SystemExit('No se reconoció la estructura del AndroidManifest.xml.')
    insertion = marker + '\n    ' + '\n    '.join(missing)
    text = text.replace(marker, insertion, 1)

text = text.replace('android:label="ecoruta"', 'android:label="EcoRuta"')
manifest.write_text(text, encoding='utf-8')
print('Android configurado para Internet, ubicación aproximada y ubicación precisa.')
