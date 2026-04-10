# pip install svgelements
import os
import xml.etree.ElementTree as ET
from svgelements import SVG

def procesar_svgs():
    base = os.path.dirname(__file__)
    assets = os.path.join(base, "..", "assets")
    log_file = os.path.join(base, "processed_files.txt")

    if not os.path.exists(assets): return

    procesados = set(open(log_file).read().splitlines()) if os.path.exists(log_file) else set()
    archivos = [f for f in os.listdir(assets) if f.endswith('.svg') and f not in procesados]

    if not archivos: return

    ET.register_namespace('', "http://www.w3.org/2000/svg")
    padding = 15

    with open(log_file, "a", encoding="utf-8") as log:
        for f in archivos:
            ruta = os.path.join(assets, f)
            try:
                bbox = SVG.parse(ruta).bbox()
                if not bbox: continue

                x, y, x2, y2 = bbox
                tree = ET.parse(ruta)
                root = tree.getroot()
                
                root.set('viewBox', f"{x-padding} {y-padding} {x2-x+padding*2} {y2-y+padding*2}")
                root.set('width', "100%")
                root.set('height', "100%")
                
                tree.write(ruta, encoding='utf-8', xml_declaration=True)
                log.write(f"{f}\n")
                print(f"Procesado: {f}")
            except Exception as e:
                print(f"Error en {f}: {e}")

if __name__ == "__main__":
    procesar_svgs()