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
                if old_style_name == "TemplateTableau":
                    # Ne pas renommer
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
      - ajoutant les lignes demandées après certaines balises
      - gérant le remplacement de {{startdoc}} ... {{enddoc}}
    """
    in_startdoc_block = False  # Pour gérer la suppression et le remplacement du bloc startdoc->enddoc

    for i, line in enumerate(lines):
        # 1) Détection <office:automatic-styles> pour ajouter la ligne $automatic-styles$
        if "<office:automatic-styles" in line:
            output.append(line)
            output.append("$automatic-styles$")
            continue

        # 2) Détection </office:master-styles> pour ajouter le bloc header-includes
        if "</office:master-styles>" in line:
            output.append(line)
            output.append("$for(header-includes)$")
            output.append("  $header-includes$")
            output.append("$endfor$")
            continue

        # 3) Détection du moment juste après :
        #    <office:body>
        #      <office:text text:use-soft-page-breaks="true">
        #    pour ajouter le bloc include-before.
        #
        # Pour simplifier, on cherche sur une même ligne ou en deux lignes successives.
        # Selon la structure du .fodt, on peut adapter.
        #
        # Ici, on teste si la ligne contient <office:body> ET la suivante contient <office:text ...
        # Mais souvent on voit <office:body> sur une ligne, puis <office:text ...> sur la ligne suivante.
        # Si votre .fodt a exactement <office:body>\n  <office:text text:use-soft-page-breaks="true">
        # sur la même ligne, il faudra adapter.
        #
        # Pour un traitement plus simple (sur la même ligne) :
        # if re.search(r"<office:body>.*<office:text text:use-soft-page-breaks=", line):
        #     ...
        #
        # Ici, on va combiner : si la ligne contient <office:body> on le met dans output
        # puis on regarde si la ligne suivante contient <office:text ...
        # Si oui, après on insère le bloc.

        if "<office:body>" in line:
            # On l'écrit d'abord
            output.append(line)
            # On regarde la ligne suivante si c'est <office:text text:use-soft-page-breaks="true">
            # (on est prudent sur l'index i+1)
            if i + 1 < len(lines) and "<office:text text:use-soft-page-breaks=" in lines[i+1]:
                # La ligne suivante sera traitée au prochain tour de boucle,
                # on va juste détecter quand on l'écrit et ajouter le bloc ensuite.
                continue
            # Sinon, on continue
            continue

        # Gestion <office:text text:use-soft-page-breaks="true">
        # Si la ligne précédente était <office:body>, alors c'est potentiellement le moment
        if "<office:text text:use-soft-page-breaks=" in line:
            output.append(line)
            # On insère juste après
            output.append("$for(include-before)$")
            output.append("$include-before$")
            output.append("$endfor$")
            continue

        # 4) Gérer le bloc {{startdoc}} ... {{enddoc}}
        if "{{startdoc}}" in line:
            # On active le mode in_startdoc_block -> on supprimera jusqu'à {{enddoc}}
            in_startdoc_block = True
            # On ne met pas la ligne dans output (on la supprime)
            continue

        if "{{enddoc}}" in line and in_startdoc_block:
            # On remplace tout ce qui se trouvait entre startdoc et enddoc (inclus)
            # par le bloc spécifié
            in_startdoc_block = False
            output.append("$body$")
            continue
        
        # 5) Juste avant </office:text>, insérer $for(include-after)$...
        if "</office:text>" in line:
            # On insère d'abord le bloc
            output.append("$for(include-after)$")
            output.append("$include-after$")
            output.append("$endfor$")
            # Puis on écrit la balise </office:text>
            output.append(line)
            continue

        # Si on est dans la zone à ignorer (entre startdoc et enddoc), on saute.
        if in_startdoc_block:
            continue

        # On ajoute la ligne modifiée
        output.append(line)


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 transform_fodt.py <fichier_entree.fodt> <fichier_sortie.fodt>")
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

