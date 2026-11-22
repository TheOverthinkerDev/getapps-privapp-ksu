import os
import zipfile

SRC = 'getapps_privapp'
OUT = 'getapps_privapp.zip'

os.chdir(os.path.dirname(os.path.abspath(__file__)))
if os.path.exists(OUT):
    os.remove(OUT)

with zipfile.ZipFile(OUT, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(SRC):
        for f in files:
            path = os.path.join(root, f)
            arc = os.path.relpath(path, SRC).replace(os.sep, '/')
            if arc.endswith(('.sh', '.prop', '.xml', '.txt')):
                # KernelSU runs these with sh: force LF line endings
                z.writestr(arc, open(path, 'rb').read().replace(b'\r\n', b'\n'))
            elif arc.endswith('.apk'):
                z.write(path, arc, compress_type=zipfile.ZIP_STORED)
            else:
                z.write(path, arc)

print('ok', OUT, os.path.getsize(OUT), 'bytes')
