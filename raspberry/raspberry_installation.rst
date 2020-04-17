Avant propos
============

Ce document est disponible sur le site
`ReadTheDocs <https://raspberry-box-installation.readthedocs.io>`__ et
sur `Github <https://github.com/apiou/vps_installation>`__.

Cette documentation décrit la méthode que j’ai utilisé pour installer
une homebox (site auto hébergé) avec un raspberry PI Elle est le
résultat de très nombreuses heures de travail pour collecter la
documentation nécessaire. Sur mon serveur, j’ai installé un Linux Debian
10. Cette documentation est facilement transposable pour des versions
différentes de Debian.

Dans ce document, je montre la configuration de nombreux types de sites
web et services dans un domaine en utilisant ISPConfig.

Sont installés:

-  un panel `ISPConfig <https://www.ispconfig.org/>`__

-  un configurateur `Webmin <http://www.webmin.com/>`__

-  un serveur apache avec sa configuration let’s encrypt et les plugins
   PHP, python et ruby

-  un serveur de mail avec antispam, sécurisation d’envoi des mails et
   autoconfiguration pour Outlook, Thunderbird, Android.

-  un webmail `roundcube <https://roundcube.net>`__,

-  un serveur de mailing list `mailman <https://www.list.org>`__,

-  un serveur ftp et sftp sécurisé.

-  un serveur de base de données et son interface web d’administration
   `phpmyadmin <https://www.phpmyadmin.net/>`__.

-  des outils de sécurisation, de mise à jour automatique et d’audit du
   serveur

-  un outil de Monitoring `Munin <http://munin-monitoring.org/>`__

-  un outil de Monitoring `Monit <http://mmonit.com/monit/>`__

-  un sous domaine pointant sur un site auto-hébergé (l’installation du
   site n’est pas décrite ici; Se référer à
   `Yunohost <https://yunohost.org>`__),

-  un site CMS sous `Joomla <https://www.joomla.fr/>`__,

-  un site CMS sous `Concrete5 <https://www.concrete5.org/>`__,

-  un site WIKI sous `Mediawiki <https://www.mediawiki.org>`__,

-  un site `Wordpress <https://wordpress.com>`__,

-  un site `Microweber <https://microweber.com>`__,

-  un site Photo sous `Piwigo <https://piwigo.org/>`__,

-  un site Collaboratif sous `Nextcloud <https://nextcloud.com>`__,

-  un site `Gitea <https://gitea.io>`__ et son repository GIT,

-  un serveur et un site de partage de fichiers
   `Seafile <https://www.seafile.com>`__,

-  un serveur `Grafana <https://grafana.com/>`__,
   `Prometheus <https://prometheus.io/>`__,
   `Loki <https://github.com/grafana/loki>`__, Promtail pour gérer les
   statistiques et les logs du serveur,

-  un serveur de sauvegardes `Borg <https://www.borgbackup.org/>`__

-  un serveur de VPN `Pritunl <https://pritunl.com/>`__,

Dans ce document nous configurons un nom de domaine principal. Pour la
clarté du texte, il sera nommé "example.com". Il est à remplacer
évidemment par votre nom de domaine principal.

Je suppose dans ce document que vous savez vous connecter à distance sur
un serveur en mode terminal, que vous savez vous servir de ``ssh`` pour
Linux ou de ``putty`` pour Windows, que vous avez des notions
élémentaires de Shell Unix et que vous savez vous servir de l’éditeur
``vi``. Si ``vi`` est trop compliqué pour vous, je vous suggère
d’utiliser l’éditeur de commande ``nano`` à la place et de remplacer
``vi`` par ``nano`` dans toutes les lignes de commande.

Dans le document, on peut trouver des textes entourés de <texte>. Cela
signifie que vous devez mettre ici votre propre texte selon vos
préférences.

A propos des mots de passe: il est conseillé de saisir des mots de passe
de 10 caractères contenant des majuscules/minuscules/nombres/caractères
spéciaux. Une autre façon de faire est de saisir de longues phrases. Par
exemple: 'J’aime manger de la mousse au chocolat parfumée à la menthe'.
Ce dernier exemple a un taux de complexité est bien meilleur que les
mots de passe classiques. Il est aussi plus facile à retenir que
'Az3~1ym\_a&'.

Le coût pour mettre en oeuvre ce type de serveur est relativement
faible: \* Compter 15-18€TTC/an pour un nom de domaine classique (mais
il peut y avoir des promos) \* Comptez 26€ pour acheter une carte
Raspberry PI 3 A+ (1Go de Ram) et 61€ pour un PI 4 avec 4Go de Ram. A
cela il faut ajouter un boitier, une alim et une flash de 64 ou 128 Go.
Vous en aurez donc pour 110€ si vous achetez tout le kit.

Par rapport à une solution VPS directement dans le cloud, ce budget
correspond à 8 mois d’abonnement.

Choix du registrar
==================

Pour rappel,un registrar est une société auprès de laquelle vous pourrez
acheter un nom de domaine sur une durée déterminée. Vous devrez fournir
pour votre enregistrement un ensemble de données personnelles qui
permettront de vous identifier en tant que propriétaire de ce nom de
domaine.

Pour ma part j’ai choisi Gandi car il ne sont pas très cher et leur
interface d’administration est simple d’usage. Vous pouvez très bien
prendre aussi vos DNS chez OVH.

Une fois votre domaine enregistré et votre compte créé vous pouvez vous
loguer sur la `plateforme de gestion de
Gandi <https://admin.gandi.net/dashboard>`__.

Allez dans Nom de domaine et sélectionnez le nom de domaine que vous
voulez administrer. La vue générale vous montre les services actifs. Il
faut une fois la configuration des DNS effectuée être dans le mode
suivant:

-  Serveurs de noms: Externes

-  Emails: Inactif

-  DNSSEC: Actif (cela sera activé dans une seconde étape de ce guide)

Vous ne devez avoir aucune boite mail active sur ce domaine. A regardez
dans le menu "Boites & redirections Mails". Vous devez reconfigurer les
'Enregistrements DNS' en mode externes. Dans le menu "serveurs de noms",
vous devez configurer les serveurs de noms externe. Mettre 3 DNS:

-  le nom de votre machine OVH: VPSxxxxxx.ovh.net

-  et deux DNS de votre domaine: ns1.<example.com> et ns2.<example.com>

Pour que tout cela fonctionne bien, ajoutez des Glue records:

-  un pour ns1.<example.com> lié à l’adresse <IP> du serveur OVH

-  un pour ns2.<example.com> lié à l’adresse <IP> du serveur OVH

Il y a la possibilité chez OVH d’utiliser un DNS secondaire. Je ne l’ai
pas mis en oeuvre.

Le menu restant est associé à DNSSEC; nous y reviendrons plus tard.
