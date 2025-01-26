#!/usr/bin/env python3

import sys
import re

def extraire_styles(lines):
    """
    Parcourt le document pour localiser les sections
    <office:automatic-styles> ... </office:automatic-styles>
    et <office:master-styles> ... </office:master-styles>
    afin de récupérer tous les style:name="..."
    On renvoie un dictionnaire {ancien_nom: nouveau_nom}, sauf pour
    - les styles commençant par '__'
    - le style nommé 'TemplateTableau'
    que l'on ne renomme pas.
    """
    in_automatic_styles = False
    in_master_styles = False
    style_map = {}

    for line in lines:
        # Détection de l'entrée/sortie des sections
        if "<office:automatic-styles" in line:
            in_automatic_styles = True
        if "</office:automatic-styles" in line:
            in_automatic_styles = False

        if "<office:master-styles" in line:
            in_master_styles = True
        if "</office:master-styles" in line:
            in_master_styles = False

        # Si on est dans la zone de styles, on cherche les style:name
        if in_automatic_styles or in_master_styles:
            # Exemple de match : style:name="Heading"
            matches = re.findall(r'style:name="([^"]+)"', line)
            for old_style_name in matches:
                # Vérifier s'il faut le renommer
                if old_style_name.startswith("__"):
                    # Ne pas renommer
                    continue
                if old_style_name.startswith("TemplateTable"):
                    # Ne pas renommer
                    continue
                if not (old_style_name.startswith('T') or old_style_name.startswith('P') or old_style_name.startswith('L') or old_style_name.startswith('fr') or old_style_name.startswith('gr') or old_style_name.startswith('dp') or old_style_name.startswith('pm') or old_style_name.startswith('Table')):
                    continue
                # Sinon, on le renomme s'il n'est pas encore dans style_map
                if old_style_name not in style_map:
                    new_style_name = "templ" + old_style_name
                    style_map[old_style_name] = new_style_name

    return style_map

def transforme_et_ecris(lines, style_map, output):
    """
    Écrit le nouveau contenu du document en :
      - remplaçant les style:name dans <office:automatic-styles> / <office:master-styles> par templXXX
      - remplaçant les text:style-name dans <office:body> par templXXX si nécessaire
    """

    for i, line in enumerate(lines):
        #    Remplacement des noms de style dans <office:automatic-styles> / <office:master-styles>
        #    OU dans <office:body>. De façon générique, dès qu'on voit style:name="XXX"
        #    on remplace par templXXX si c'est dans le style_map.
        #
        #    Idem pour text:style-name="XXX"
        #
        #    On peut le faire via une fonction substituant chaque nom trouvé :
        def replace_style_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'style:name="{style_map[old_name]}"'
            else:
                return match.group(0)  # inchangé

        def replace_text_style_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'text:style-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        def replace_draw_style_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'draw:style-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        def replace_style_page_layout_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'style:page-layout-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        def replace_style_next_style_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'style:next-style-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        def replace_draw_text_style_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'draw:text-style-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        def replace_table_style_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'table:style-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        def replace_style_master_page_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'style:master-page-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        def replace_style_parent_style_name(match):
            old_name = match.group(1)
            if old_name in style_map:
                return f'style:parent-style-name="{style_map[old_name]}"'
            else:
                return match.group(0)

        new_line = line
        # a) Supprimer la balise meta:generator si elle est présente dans la ligne
        #    (et tout son contenu)
        new_line = re.sub(r'<meta:generator>.*?</meta:generator>', '', new_line)

        # b) Remplacer style:name="XXX"
        new_line = re.sub(r'style:name="([^"]+)"', replace_style_name, new_line)
        # c) Remplacer text:style-name="XXX"
        new_line = re.sub(r'text:style-name="([^"]+)"', replace_text_style_name, new_line)
        # d) Remplacer draw:style-name="XXX"
        new_line = re.sub(r'draw:style-name="([^"]+)"', replace_draw_style_name, new_line)
        # e) Remplacer style:page-layout-name="XXX"
        new_line = re.sub(r'style:page-layout-name="([^"]+)"', replace_style_page_layout_name, new_line)
        # f) Remplacer style:next-style-name="XXX"
        new_line = re.sub(r'style:next-style-name="([^"]+)"', replace_style_next_style_name, new_line)
        # f) Remplacer draw:text-style-name="XXX"
        new_line = re.sub(r'draw:text-style-name="([^"]+)"', replace_draw_text_style_name, new_line)
        # f) Remplacer table:style-name="XXX"
        new_line = re.sub(r'table:style-name="([^"]+)"', replace_table_style_name, new_line)
        # g) Remplacer table:style:master-page-name="XXX"
        new_line = re.sub(r'style:master-page-name="([^"]+)"', replace_style_master_page_name, new_line)
        # h) Remplacer style:parent-style-name="XXX"
        new_line = re.sub(r'style:parent-style-name="([^"]+)"', replace_style_parent_style_name, new_line)

        # On ajoute la ligne modifiée
        output.append(new_line)


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 style.py <fichier_entree.fodt> <fichier_sortie.fodt>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    # Lecture du contenu
    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    # 1) On construit la map de styles
    style_map = extraire_styles(lines)

    # 2) On réécrit en transformant
    output_lines = []
    transforme_et_ecris(lines, style_map, output_lines)

    # Écriture du résultat
    with open(output_file, "w", encoding="utf-8") as f:
        for l in output_lines:
            f.write(l if l.endswith("\n") else l + "\n")


if __name__ == "__main__":
    main()

