# Comment générer un document template pour Pandoc et le format ODT

Pandoc offre la possibilité de générer des fichiers ODT à partir d'un template.
Il y a peu de doc sur internet sur le sujet, car peu de personnes sont intéressées (Les développeurs qui utilisent pandoc, génèrent peu de doc à usage externe)

## Création du template de style de référence

Il faut créer un document de template de référence. C'est obligatoire pour que pandoc s'y retrouve.

Tapez la commande suivante :

```
make prepare
```

Un document frame.fodt est créé dans le répertoire. S'il en existait déjà un, il est recopié sur le nom frame_old.fodt

## Création du template de document

Editez ensuite avec libreoffice le document frame.odt.

Faites des modifications élémentaires et effectuez des essais avec le fichier `test.asc` pour vérifier le rendu des styles.

Afin de générer le document résultat, tapez:
+
```
make test_style
```

Vérifiez le résultat dans le fichier `test.fodt` et effectuez des modifications dans `frame.fodt` jusqu'à ce que le rendu du document soit conforme au template d'entreprise tant sur les styles que sur les pages de gardes.

Vous pouvez vérifier les versions générées en pdf et docx.

NOTE: Vous n'aurez pas de rendu de template avec cette commande. Il vous faudra générer le template (étape suivante) pour voir votre document.

## Injecter les balises de templating dans le document

Le fichier supporte un certain nombre de balises de templating. Elles sont pour la plupart encadrées par une double accolade comme: `{{author}}`

Les balises sont les suivantes:

* `{{title}}`: affiche le titre du document
* `{{subtitle}}`: affiche le sous-titre du document s'il existe
* `{{revision}}`: affiche la version du document
* `{{date}}`: affiche la date du document (soit stockée dans le fichier asciidoctor sinon la date du fichier asciidoctor)
* `{{author}}`: l'auteur du document (Prénom et Nom)
* `{{email}}`: l'email de l'auteur du document (s'ils est renseigné)
* `{{authorfirstname}}`: Le prénom de l'auteur
* `{{authorsurname}}`: Le nom de famille de l'auteur
* `{{authorinitials}}`: les initiales de l'auteur
* `{{reviewername}}`: le nom du relecteur (Prénom et Nom)
* `{{reviewertitle}}`: le titre du relecteur ( exemple: Responsable infra )
* `{{approvername}}`: le nom de l'approbateur (Prénom et Nom)
* `{{approvertitle}}`: le titre de l'approbateur
* `{{startrev}}` et `{{endrev}}` définissent le début et la fin de la zone à dupliquer dans le template documentaire pour ajouter une ligne de révision du document. Ces deux items doivent encadrer tous les champs de type `{{revision}}`. Ils se trouvent habituellement dans un tableau `{{startrev}}` est sur la première ligne du tableau et `{{endrev}}` est sur la deuxième ligne du tableau.
* `{{revision}}`: cette macro ne peut pas être utilisée seule mais avec ses composantes. Ici sont stockées toutes les lignes de révision du document telles que définies dans le document asciidoctor
** `{{revision.version}}`: numéro de version de la révision documentaire
** `{{revision.author}}`: initiales de l'auteur de la révision documentaire
** `{{revision.date}}`: date de publication de cette révision documentaire
** `{{revision.comment}}`: explication des modifications réalisées dans cette version documentaire
* `{{startdoc}}`: cette balise sert à indiquer ou se trouve le corps du document. C'est à dire l'endroit dans le template documentaire ou sera injecté le contenu des documents asciidoctor.
* `{{enddoc}}`: indique la fin de la zone ou doit se trouver le corps de texte. Tout ce qui se trouve après est conservé en état et est considéré comme faisant partie du template.

Les balises suivantes sont celles généres nativement par asciidoctor:

* `$title$`: titre du document (géré par asciidoctor)
* `$subtitle$`: sous-titre du document (géré par asciidoctor)
* `$author$`: auteur du document (inclut l'adresse mail (géré par asciidoctor))
* `$date$`: date du document (géré par asciidoctor)

Par défaut les tableaux n'ont pas de formatage et de bords. Il est possible de définir un tableau de référence qui sera nommé `ReferenceTable` les attributs de bord, remplissage et couleurs seront recopiés de ce tableau de référence vers tous les autres tableaux du document sauf ceux dont le nom commence par `__`.

A noter qu'il faut absolument que ce tableau de référence soit présent quelque part dans le document (la taille n'importe pas). il peut être mis dans des zones cachée de la première page par exemple. Le fichier `reference.fodt` en contient un.

Ce système de copie pour les tables sera simplifié dès que les outils libreoffice ou pandoc implémenteront nativement le formatage de tableau.

## Préparation du template

Tapez la commande:
+
```
make generate_template
```

Elle vous préparera le fichier `style.odt` et le fichier `template.fodt` pour la génération des documents définifs.

## Test du template

Vous pouvez maintenant tester le template généré.

Pour cela tapez:
+
```
make test_template
```

Tous les documents cibles seront générés dans le répertoire courant à partir du fichier test.asc.

Si votre document est au bon format, les fichiers résultat prendront en compte le template de frame.fodt.
