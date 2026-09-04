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
    <item>
        <shape android:shape="rectangle">
            <solid android:color="#FFFDF7" />
        </shape>
    </item>
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


def patch_brand_mark() -> None:
    path = ROOT / 'lib' / 'widgets' / 'ecoruta_widgets.dart'
    text = path.read_text(encoding='utf-8')
    old = '''class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66A34A)],
          ),
          borderRadius: BorderRadius.circular(size * .28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.eco, color: Colors.white, size: size * .55),
      ),
    );
  }
}
'''
    new = '''class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * .06),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * .28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * .22),
          child: Image.asset(
            'assets/branding/icon.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
'''
    if old not in text:
        raise SystemExit('No se encontró BrandMark para aplicar el branding.')
    path.write_text(text.replace(old, new, 1), encoding='utf-8')


def patch_login_screen() -> None:
    path = ROOT / 'lib' / 'screens' / 'auth_screens.dart'
    text = path.read_text(encoding='utf-8')
    old = '''                    const BrandMark(size: 88),
                    const SizedBox(height: 20),
'''
    new = '''                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/branding/splash_logo.png',
                        height: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 18),
'''
    if old not in text:
        raise SystemExit('No se encontró el área de logo del LoginScreen.')
    path.write_text(text.replace(old, new, 1), encoding='utf-8')


def patch_home_screen() -> None:
    path = ROOT / 'lib' / 'screens' / 'main_screens.dart'
    text = path.read_text(encoding='utf-8')

    title_old = "        title: const Text('EcoRuta'),\n"
    title_new = '''        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/branding/icon.png',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'EcoRuta',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
'''
    if title_old not in text:
        raise SystemExit('No se encontró el título del HomeScreen.')
    text = text.replace(title_old, title_new, 1)

    row_old = '              child: const Row(\n'
    row_new = '              child: Row(\n'
    if row_old not in text:
        raise SystemExit('No se encontró el banner principal del HomeScreen.')
    text = text.replace(row_old, row_new, 1)

    icon_old = '                  Icon(Icons.eco, color: Colors.white, size: 56),\n'
    icon_new = '''                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/branding/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
'''
    if icon_old not in text:
        raise SystemExit('No se encontró el icono del banner del HomeScreen.')
    text = text.replace(icon_old, icon_new, 1)

    path.write_text(text, encoding='utf-8')


def patch_flutter_ui() -> None:
    patch_brand_mark()
    patch_login_screen()
    patch_home_screen()


def main() -> None:
    icon_bytes = decode(ICON_B64, ICON_PNG)
    splash_bytes = decode(SPLASH_B64, SPLASH_PNG)
    write_android_launcher(icon_bytes)
    write_native_splash(splash_bytes)
    patch_flutter_ui()
    print(
        'Branding EcoRuta generado: icono Android + splash + logo en Login e Inicio.'
    )


if __name__ == '__main__':
    main()
