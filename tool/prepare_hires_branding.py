import base64
import hashlib
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BRANDING = ROOT / 'assets' / 'branding'
PARTS_DIR = BRANDING / 'master_parts'
ICON_B64 = BRANDING / 'icon.b64'


def validate_png(raw: bytes) -> tuple[int, int]:
    if not raw.startswith(b'\x89PNG\r\n\x1a\n'):
        raise SystemExit('El logo maestro no es un PNG válido.')
    if len(raw) < 33:
        raise SystemExit('El logo maestro está truncado.')

    width, height = struct.unpack('>II', raw[16:24])
    if width < 1024 or height < 1024:
        raise SystemExit(
            f'Logo maestro insuficiente: {width}x{height}. '
            'Se requiere al menos 1024x1024.'
        )

    pos = 8
    idat = bytearray()
    saw_iend = False
    while pos + 12 <= len(raw):
        length = struct.unpack('>I', raw[pos:pos + 4])[0]
        chunk_type = raw[pos + 4:pos + 8]
        end = pos + 12 + length
        if end > len(raw):
            raise SystemExit('El logo maestro está truncado.')
        if chunk_type == b'IDAT':
            idat.extend(raw[pos + 8:pos + 8 + length])
        if chunk_type == b'IEND':
            saw_iend = True
            break
        pos = end

    if not idat or not saw_iend:
        raise SystemExit('El logo maestro está incompleto.')

    try:
        zlib.decompress(bytes(idat))
    except zlib.error as exc:
        raise SystemExit(f'El logo maestro tiene datos PNG dañados: {exc}') from exc

    return width, height


def main() -> None:
    parts = sorted(PARTS_DIR.glob('part*.b64'))
    if not parts:
        raise SystemExit('No se encontraron partes del logo maestro.')

    encoded = ''.join(p.read_text(encoding='utf-8').strip() for p in parts)
    try:
        raw = base64.b64decode(encoded, validate=True)
    except Exception as exc:
        raise SystemExit(f'Base64 del logo maestro inválido: {exc}') from exc

    width, height = validate_png(raw)
    digest = hashlib.sha256(raw).hexdigest()
    ICON_B64.write_text(encoded, encoding='utf-8')
    print(
        f'Logo maestro validado: {width}x{height}, '
        f'{len(raw)} bytes, sha256={digest}'
    )


if __name__ == '__main__':
    main()
