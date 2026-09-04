import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BRANDING = ROOT / 'assets' / 'branding'
ICON_B64 = BRANDING / 'icon.b64'
SPLASH_B64 = BRANDING / 'splash.b64'
ICON_PNG = BRANDING / 'icon.png'
SPLASH_PNG = BRANDING / 'splash_logo.png'


def decode(source: Path, target: Path) -> bytes:
    if not source.exists():
        raise SystemExit(f'No se encontró {source.relative_to(ROOT)}')
    raw = base64.b64decode(source.read_text(encoding='utf-8').strip())
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(raw)
    return raw


def write_android_launcher(icon_bytes: bytes) -> None:
    res = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'
    if not res.exists():
        raise SystemExit('No existe android/app/src/main/res. Ejecuta flutter create primero.')

    # Android puede escalar el PNG para las diferentes densidades. Usamos el
    # mismo arte final para conservar exactamente la identidad visual aprobada.
    for density in ('mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'):
        target = res / f'mipmap-{density}' / 'ic_launcher.png'
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(icon_bytes)


def write_native_splash(splash_bytes: bytes) -> None:
    res = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'
    nodpi = res / 'drawable-nodpi'
    nodpi.mkdir(parents=True, exist_ok=True)
    (nodpi / 'ecoruta_splash.png').write_bytes(splash_bytes)

    launch_xml = '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="#FFFDF7" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@drawable/ecoruta_splash" />
    </item>
</layer-list>
'''
    for folder in ('drawable', 'drawable-v21'):
        target_dir = res / folder
        target_dir.mkdir(parents=True, exist_ok=True)
        (target_dir / 'launch_background.xml').write_text(
            launch_xml,
            encoding='utf-8',
        )


def main() -> None:
    icon_bytes = decode(ICON_B64, ICON_PNG)
    splash_bytes = decode(SPLASH_B64, SPLASH_PNG)
    write_android_launcher(icon_bytes)
    write_native_splash(splash_bytes)
    print('Branding EcoRuta generado: icono Android + splash + assets Flutter.')


if __name__ == '__main__':
    main()
