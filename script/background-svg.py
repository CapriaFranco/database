#!/usr/bin/env python3
# Añade un fondo blanco a un SVG seleccionado dentro de la carpeta assets
import os
import xml.etree.ElementTree as ET

def list_svgs(assets_dir):
    return sorted([f for f in os.listdir(assets_dir) if f.lower().endswith('.svg')])

def add_white_bg(path):
    ET.register_namespace('', "http://www.w3.org/2000/svg")
    tree = ET.parse(path)
    root = tree.getroot()
    ns = ''
    if root.tag.startswith('{'):
        ns = root.tag[1:root.tag.find('}')]
    rect_tag = f"{{{ns}}}rect" if ns else 'rect'

    # eliminar fondo previo con id="bg"
    for p in root.iter():
        for c in list(p):
            if c.get('id') == 'bg':
                p.remove(c)

    # determinar área: preferir viewBox, si no, intentar bbox con svgelements, si no, usar width/height
    minx = miny = 0.0
    w = h = None
    vb = root.get('viewBox')
    if vb:
        try:
            a = [float(x) for x in vb.replace(',', ' ').split() if x.strip()]
            if len(a) == 4:
                minx, miny, w, h = a
        except Exception:
            pass

    if w is None or h is None:
        try:
            from svgelements import SVG
            bbox = SVG.parse(path).bbox()
            if bbox:
                x1, y1, x2, y2 = bbox
                minx, miny = x1, y1
                w, h = x2 - x1, y2 - y1
        except Exception:
            pass

    if w is None or h is None:
        # intentar atributos width/height (si son numéricos)
        aw = root.get('width')
        ah = root.get('height')
        def parse_num(s):
            if not s: return None
            s = s.strip()
            if s.endswith('%'): return None
            for u in ('px', 'pt', 'cm', 'mm', 'in'):
                if s.endswith(u):
                    s = s[:-len(u)]
                    break
            try:
                return float(s)
            except Exception:
                return None
        nw = parse_num(aw)
        nh = parse_num(ah)
        if nw is not None and nh is not None:
            minx, miny = 0.0, 0.0
            w, h = nw, nh

    if w is None or h is None:
        # último recurso: usar 100% (aunque puede no cubrir viewBox con offset)
        attrs = {'x':'0','y':'0','width':'100%','height':'100%','fill':'#FFFFFF','id':'bg'}
    else:
        attrs = {'x':str(minx),'y':str(miny),'width':str(w),'height':str(h),'fill':'#FFFFFF','id':'bg'}

    rect = ET.Element(rect_tag, attrs)

    # insertar después de <defs> si existe, sino al inicio
    insert_idx = 0
    children = list(root)
    for i, child in enumerate(children):
        tag_local = child.tag.split('}', 1)[-1] if '}' in child.tag else child.tag
        if tag_local == 'defs':
            insert_idx = i + 1

    root.insert(insert_idx, rect)
    out = os.path.splitext(path)[0] + '_bg.svg'
    tree.write(out, encoding='utf-8', xml_declaration=True)
    print(f"Guardado: {os.path.basename(out)}")

def main():
    base = os.path.dirname(__file__)
    assets = os.path.join(base, '..', 'assets')
    if not os.path.exists(assets):
        print('Carpeta assets no encontrada.')
        return
    svgs = list_svgs(assets)
    if not svgs:
        print('No hay archivos .svg en assets.')
        return
    for i, f in enumerate(svgs, 1):
        print(f"{i}: {f}")
    try:
        n = int(input('Ingrese el número del SVG: ').strip())
        if n < 1 or n > len(svgs):
            print('Número inválido.')
            return
    except Exception:
        print('Entrada inválida.')
        return
    seleccionado = os.path.join(assets, svgs[n-1])
    add_white_bg(seleccionado)

if __name__ == '__main__':
    main()
