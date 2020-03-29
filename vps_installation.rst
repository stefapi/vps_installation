Avant propos
============

Ce document est disponible sur le site
`ReadTheDocs <https://vps-installation.readthedocs.io>`__ |badge| et sur
`Github <https://github.com/apiou/vps_installation>`__.

Cette documentation décrit la méthode que j’ai utilisé pour installer un
serveur VPS sur la plate-forme OVH. Elle est le résultat de très
nombreuses heures de travail pour collecter la documentation nécessaire.
Sur mon serveur, j’ai installé un Linux Debian 10. Cette documentation
est facilement transposable pour des versions différentes de Debian ou à
Ubuntu ou toute autre distribution basée sur l’un ou l’autre. En
revanche si vous utilisez CentOS, il y aura des différences beaucoup
plus importantes notamment liées au gestionnaire de paquets ``yum``, le
nommage des paquets, les configurations par défaut et aux différences
dans l’arborescence présente dans /etc.

Dans ce document nous configurons un nom de domaine principal. Pour la
clarté du texte, il sera nommé "example.com". Il est à remplacer
évidemment par votre nom de domaine principal.

Je suppose dans ce document que vous savez vous connecter à distance sur
un serveur en mode terminal. Donc que vous savez vous servir de ``ssh``
pour Linux ou de ``putty`` pour Windows

Dans le document, on peut trouver des textes entourés de <texte>. Cela
signifie que vous devez mettre ici votre propre texte selon vos
préférences. Si le texte ne doit pas contenir d’espace, la phrase
contient elle même des \_ ou des - pour l’indiquer en fonction de ce qui
est autorisé.

A propos des mots de passe: il est conseillé de saisir des mots de passe
de 10 caractères contenant des majuscules/minuscules/nombres/caractères
spéciaux. Une autre façon de faire est de saisir de longues phrases. Par
exemple: 'J’aime manger de la mousse au chocolat parfumée à la menthe'.
Le taux de complexité est bien meilleur et les mots de passe sont plus
facile à retenir que 'Az3~1ym\_a&'

Le cout pour avoir ce type de serveur est relativement faible: \*
Compter 15-18€TTC/an pour un nom de domaine classique (mais il peut y
avoir des promos) \* Compter 5€TTC/mois pour un VPS de base.

Le budget est donc de 6-7€TTC/mois pour une offre d’entrée de gamme

Choix du VPS
============

Cette partie du guide s’adresse aux utilisateurs d’OVH. J’ai pour ma
part choisi un serveur VPS SSD chez OVH avec 2Go de RAM. Au moment ou
j’écris ce document il possède un seul coeur et 20 Go de disque.

Choisissez d’installer une image Linux seule avec Debian 10. Une fois
l’installation effectuée, vous recevez un Email sur l’adresse mail de
votre compte OVH avec vos identifiants de login root. Ils serviront à
vous connecter sur le serveur.

En vous loguant sur la `plateforme d’administration
d’OVH <https://www.ovh.com/manager/web>`__, vous accèderez aux
informations de votre serveur dans le menu Server→VPS. A cet endroit
votre VPS doit y être indiqué.

En cliquant dessus un ensemble de menus doivent apparaitre pour
administrer celui-ci. Vous y trouverez notamment:

-  Son adresse <IP> et le nom de la machine chez OVH. Elle est du type
   "VPSxxxxxx.ovh.net"

-  La possibilité de le redémarrer

-  La possibilité de le reinstaller (avec perte complète de données)

-  un KVM pour en prendre le controle console directement dans le
   navigateur

-  un menu de configuration de reverse DNS (qui nous sera utile par la
   suite) pour définir le domaine par défaut

-  le statut des services principaux (http, ftp, ssh …​)

-  enfin des choix pour souscrire à un backup régulier, ajouter des
   disques ou effecter un snapshot de la VM associée au VPS.

Choix du registrar
==================

Pour ma part j’ai choisi Gandi car il ne sont pas très cher et leur
interface d’administration est simple d’usage. Vous pouvez très bien
prendre aussi vos DNS chez OVH. Une fois votre domaine enregistré et
votre compte créé vous pouvez vous loguer sur la `plateforme de gestion
de Gandi <https://admin.gandi.net/dashboard>`__. Allez dans Nom de
domaine et sélectionnez le nom de domaine que vous voulez administrer.
La vue générale vous montre les services actifs. Il faut une fois la
configuration des DNS effectuée être dans le mode suivant:

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

Se loguer root sur le serveur
=============================

A de nombreux endroit dans la documentation, il est demandé de se loguer
root sur le serveur. Pour se loguer root, et dans l’hypothèse que vous
avez mis en place un compte sudo:

1. De votre machine locale, loguez vous avec votre compte
   ``<sudo_username>``. Tapez :

   .. code:: bash

       ssh <sudo_username>@<example.com> 

   -  Mettez ici <sudo\_username> par votre nom de login et
      <example.com> par votre nom de domaine. Au début votre nom de
      domaine acheté n’est pas encore configuré. Il faut donc utiliser
      le nom de machine de votre VPS (pour ovh: VPSxxxxxx.ovh.net).

   ou utilisez putty si vous êtes sous Windows.

2. Tapez votre mot de passe s’il est demandé. Si vous avez installé une
   clé de connexion ce ne devrait pas être le cas.

3. Loguez-vous ``root``. Tapez :

   .. code:: bash

       sudo bash

   Un mot de passe vous est demandé. Tapez le mot de passe demandé.

4. Dans le cas contraire (pas de sudo créé et connexion en root directe
   sur le serveur):

   a. Se loguer root sur le serveur distant. Tapez:

      .. code:: bash

          ssh root@<example.com> 

      -  remplacer ici <example.com> par votre nom de domaine.

      Tapez ensuite votre mot de passe root

Installation basique
====================

Vérification du nom de serveur
------------------------------

Cette partie consiste à vérifier que le serveur a un hostname
correctement configuré.

1. Se loguer ``root`` sur le serveur

2. vérifier que le hostname est bien celui attendu (c’est à dire
   configuré par votre hébergeur). Tapez :

   .. code:: bash

       cat /etc/hostname

   Le nom du hostname (sans le domaine) doit s’afficher.

   a. Si ce n’est pas le cas, changer ce nom en éditant le fichier.
      Tapez :

      .. code:: shell

          vi /etc/hostname

      Changez la valeur, sauvegardez et rebootez. Tapez :

      .. code:: bash

          reboot

   b. Se loguer\`root\` de nouveau sur le serveur

3. Vérifier le fichier ``hosts``. Tapez :

   .. code:: bash

       cat /etc/hosts

   Si le fichier contient plusieurs lignes avec la même adresse de
   loopback en ``127.x.y.z``, en gardez une seule et celle avec le
   hostname et le nom de domaine complet.

   a. si ce n’est pas le cas, changer les lignes en éditant le fichier.
      Tapez:

      .. code:: bash

          vi /etc/hosts

      Changez la ou les lignes, sauvegardez et rebootez. Tapez :

      .. code:: bash

          reboot

   b. Se logger\`root\` de nouveau sur le serveur

4. Vérifiez que tout est correctement configuré.

   a. Tapez :

      .. code:: bash

          hostname

      La sortie doit afficher le nom de host.

   b. Tapez ensuite :

      .. code:: bash

          hostname -f

      La sortie doit afficher le nom de host avec le nom de domaine.

Interdire le login direct en root
---------------------------------

Il est toujours vivement déconseillé d’autoriser la possibilité de se
connecter directement en SSH en tant que root. De ce fait, notre
première action sera de désactiver le login direct en root et
d’autoriser le sudo. Respectez bien les étapes de cette procédure:

1. Se loguer ``root`` sur le serveur

2. Ajoutez un utilisateur standard qui sera nommé par la suite en tant
   que <sudo\_username>

   a. Tapez :

      .. code:: bash

          adduser <sudo_username>

   b. Répondez aux questions qui vont sont posées: habituellement le nom
      complet d’utilisateur et le mot de passe.

   c. Donner les attributs sudo à l’utilisateur ``<sudo_username>``.
      Tapez :

      .. code:: bash

          usermod -a -G sudo <sudo_username>

   d. Dans une autre fenêtre, se connecter sur le serveur avec votre
      nouveau compte ``<sudo_username>``:

      .. code:: bash

          ssh <sudo_username>@<example.com> 

      -  remplacer ici <sudo\_username> par votre login et <example.com>
         par votre nom de domaine

   e. une fois logué, tapez:

      .. code:: bash

          sudo bash

      Tapez le mot de passe de votre utilisateur. Vous devez avoir accès
      au compte root. Si ce n’est pas le cas, revérifiez la procédure et
      repassez toutes les étapes.

    **Important**

    Tout pendant que ces premières étapes ne donnent pas satisfaction ne
    passez pas à la suite sous peine de perdre la possibilité d’accéder
    à votre serveur.

1. Il faut maintenant modifier la configuration de sshd.

   a. Editez le fichier ``/etc/ssh/sshd_config``, Tapez:

      .. code:: bash

          vi /etc/ssh/sshd_config

      il faut rechercher la ligne: ``PermitRootLogin yes`` et la
      remplacer par: ``PermitRootLogin no``

   b. Redémarrez le serveur ssh. Tapez :

      .. code:: bash

          service sshd restart

2. Faites maintenant l’essai de vous re-loguer avec le compte root.Tapez
   :

   .. code:: bash

       ssh root@<example.com> 

   -  Remplacer ici <example.com> par votre nom de domaine

3. Ce ne devrait plus être possible: le serveur vous l’indique par un
   message ``Permission denied, please try again.``

Création d’une clé de connexion ssh
-----------------------------------

Pour créer une clé et la déployer:

1. Créez une clé sur votre machine locale:

   a. Ouvrir un terminal

   b. Créer un répertoire ``~/.ssh`` s’il n’existe pas. tapez :

      .. code:: bash

          mkdir -p $HOME/.ssh

   c. Allez dans le répertoire. Tapez :

      .. code:: bash

          cd ~/.ssh

   d. Générez vous clés. Tapez :

      .. code:: bash

          ssh-keygen -t rsa

   e. Un ensemble de questions apparaît. Si un texte vous explique que
      le fichier existe déjà, arrêtez la procédure. Cela signifie que
      vous avez déjà créé une clé et que vous risquez de perdre la
      connexion à d’autres serveurs si vous en générez une nouvelle.
      Sinon, appuyez sur Entrée à chaque fois pour accepter les valeurs
      par défaut.

2. Déployez votre clé:

   a. Loguez vous sur votre serveur distant. Tapez :

      .. code:: bash

          ssh <sudo_username>@<example.com> 

      -  remplacer ici <sudo\_username> par votre login et <example.com>
         par votre nom de domaine

      Entrez votre mot de passe

   b. Créer un répertoire ``~/.ssh`` s’il n’existe pas. tapez: :

      .. code:: bash

          mkdir -p $HOME/.ssh

   c. Éditez le fichier ``~/.ssh/authorized_keys`` tapez:

      .. code:: bash

          vi ~/.ssh/authorized_keys

      et coller dans ce fichier le texte contenu dans le votre fichier
      local ``~/.ssh/id_rsa.pub``. Remarque: il peut y avoir déjà des
      clés dans le fichier ``authorized_keys``.

   d. Sécurisez votre fichier de clés. Tapez: :

      .. code:: bash

          chmod 600 ~/.ssh/authorized_keys

   e. Sécurisez le répertoire SSH; Tapez :

      .. code:: bash

          chmod 700 ~/.ssh

   f. Déconnectez vous de votre session

3. Vérifiez que tout fonctionne en vous connectant. Tapez: :

   .. code:: bash

       ssh <sudo_username>@<example.com> 

   -  remplacer ici <sudo\_username> par votre login et <example.com>
      par votre nom de domaine

   La session doit s’ouvrir sans demander de mot de passe.

Sudo sans mot de passe
----------------------

Avant tout, il faut bien se rendre compte que cela constitue
potentiellement une faille de sécurité et qu’en conséquence, le compte
possédant cette propriété devra être autant sécurisé qu’un compte root.
L’intérêt étant d’interdire le compte root en connexion ssh tout en
gardant la facilité de se loguer root sur le système au travers d’un
super-compte.

1. Ajoutez un groupe sudonp et y affecter un utilisateur. Tapez :

   .. code:: bash

       addgroup --system sudonp

   a. Ajouter l’utilisateur: :

      .. code:: bash

          usermod -a -G sudonp <sudo_username>

   b. Éventuellement retirez l’utilisateur du groupe sudo s’il a été
      ajouté auparavant :

      .. code:: bash

          gpasswd -d -G sudo <sudo_username>

   c. Éditez le fichier sudoers. Tapez :

      .. code:: bash

          vi /etc/sudoers

   d. Ajouter dans le fichier la ligne suivante:
      ``%sudonp ALL=(ALL:ALL) NOPASSWD: ALL``

L’utilisateur nom\_d\_utilisateur pourra se logger root sans mot de
passe au travers de la commande ``sudo bash``

Mise à jour des sources de paquets Debian
-----------------------------------------

1. Se loguer ``root`` sur le serveur

2. Modifier la liste standard de paquets

   a. Éditer le fichier ``/etc/apt/sources.list``. Tapez:

      .. code:: bash

          vi /etc/apt/sources.list

   b. Dé-commenter les lignes débutant par ``deb`` et contenant le terme
      ``backports``. Par exemple pour
      ``#deb http://deb.debian.org/debian buster-backports main contrib non-free``
      enlever le # en début de ligne

   c. Ajouter sur toutes les lignes les paquets ``contrib`` et
      ``non-free`` . en ajoutant ces textes après chaque mot ``main`` du
      fichier ``source.list``

3. Effectuer une mise à niveau du système

   a. Mettez à jour la liste des paquets. Tapez:

      .. code:: bash

          apt update

   b. Installez les nouveautés. Tapez:

      .. code:: bash

          apt dist-upgrade

4. Effectuez du ménage. Tapez:

   .. code:: bash

       apt autoremove

Ajouter un fichier de swap
--------------------------

Pour un serveur VPS de 2 Go de RAM, la taille du fichier de swap sera de
1 Go:

1. Tapez:

   .. code:: bash

       fallocate -l 1G /swapfile
       chmod 600 /swapfile
       mkswap /swapfile
       swapon /swapfile

2. Enfin ajoutez une entrée dans le fichier fstab. Tapez
   ``vi /etc/fstab`` et ajoutez la ligne:
   ``/swapfile swap swap defaults 0 0``

Installation des paquets de base
--------------------------------

1. tapez:

   .. code:: bash

       apt install curl wget ntpdate apt-transport-https apt-listchanges apt-file apt-rdepends

2. Si vous souhaitez installer automatiquement les paquets Debian de
   correction de bugs de sécurité, tapez:

   .. code:: bash

       apt install unattended-upgrades

Installation d’un Panel
-----------------------

Il existe plusieurs type de panel de contrôle pour les VPS. La plupart
sont payant.

Ci après nous allons en présenter 3 différents. Ils sont incompatibles
entre eux. On peut faire cohabiter ISPConfig et Webmin en prenant les
précautions suivantes: \* ISPConfig est le maitre de la configuration:
toute modification sur les sites webs, mailboxes et DNS doit
impérativement être effectuées du coté d’ISPConfig \* Les modifications
réalisées au niveau de webmin pour ces sites webs, mailboxes et DNS
seront au mieux écrasées par ISPConfig au pire elles risquent de
conduire à des incompatibilités qui engendreront des dysfonctionnement
d’ISPConfig (impossibilité de mettre à jour les configurations) \* Le
reste des modifications peuvent être configurées au niveau de webmin
sans trop de contraintes.

Installation de Hestia
----------------------

Hestia est basé sur VestaCP. C’est une alternative opensource et plus
moderne de cet outiL. La documentation est proposée ici:
https://docs.hestiacp.com/

Attention Hestia n’est pas compatible de Webmin dans le sens que webmin
est incapable de lire et d’interpréter les fichiers créés par Hestia.

De même, Hestia est principalement compatible de PHP. Si vous utilisez
des système web basés sur des applicatifs écrits en Python ou en Ruby,
la configuration sera à faire à la main avec tous les problèmes de
compatibilité que cela impose.

Pour installer:

1. Se logger ``root`` sur le serveur

2. Télécharger le package et lancez l’installeur

   a. Tapez :

      .. code:: bash

          wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh

   b. Lancez l’installeur. Tapez :

      .. code:: bash

          bash hst-install.sh -g yes -o yes

   c. Si le système n’est pas compatible, HestiaCP vous le dira. Sinon,
      il vous informe de la configuration qui sera installée. Tapez
      ``Y`` pour continuer.

   d. Entrez votre adresse mail standard et indépendante du futur
      serveur qui sera installé. ce peut être une adresse gmail.com par
      exemple.

3. Hestia est installé. Il est important de bien noter le mot de passe
   du compte admin de Hestia ainsi que le numéro de port du site web

Installation de ISPconfig
-------------------------

Installation initiale
~~~~~~~~~~~~~~~~~~~~~

ISPConfig est un système de configuration de sites web totalement
compatible avec Webmin.

La procédure d’installation ci-dessous configure ISPconfig avec les
fonctionnalités suivantes: Postfix, Dovecot, MariaDB, rkHunter, Amavisd,
SPamAssassin, ClamAV, Apache, PHP, Let’s Encrypt, Mailman, PureFTPd,
Bind, Webalizer, AWStats, fail2Ban, UFW Firewall, PHPMyadmin, RoundCube.

1. Se loguer ``root`` sur le serveur

2. Changez le Shell par défaut. Tapez :

   .. code:: bash

       dpkg-reconfigure dash.

   A la question ``utilisez dash comme shell par défaut`` répondez
   ``non``. C’est bash qui doit être utilisé.

3. Installation de quelques paquets debian. ;-)

   a. Tapez :

      .. code:: bash

          apt install patch ntp postfix postfix-mysql postfix-doc mariadb-client mariadb-server openssl getmail4 rkhunter binutils dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd amavisd-new spamassassin clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract p7zip p7zip-full unrar lrzip libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl libdbd-mysql-perl postgrey apache2 apache2-doc apache2-utils libapache2-mod-php php7.3 php7.3-common php7.3-gd php7.3-mysql php7.3-imap php7.3-cli php7.3-cgi libapache2-mod-fcgid apache2-suexec-pristine php-pear mcrypt  imagemagick libruby libapache2-mod-python php7.3-curl php7.3-intl php7.3-pspell php7.3-recode php7.3-sqlite3 php7.3-tidy php7.3-xmlrpc php7.3-xsl memcached php-memcache php-imagick php-gettext php7.3-zip php7.3-mbstring memcached libapache2-mod-passenger php7.3-soap php7.3-fpm php7.3-opcache php-apcu bind9 dnsutils haveged webalizer awstats geoip-database libclass-dbi-mysql-perl libtimedate-perl fail2ban ufw

4. Aux questions posées répondez:

   a. ``Type principal de configuration de mail``: ← Sélectionnez
      ``Site Internet``

   b. ``Nom de courrier``: ← Entrez votre nom de host. Par exemple:
      mail.example.com

Configuration de Postfix
~~~~~~~~~~~~~~~~~~~~~~~~

1. Editez le master.cf file de postfix. Tapez
   ``vi /etc/postfix/master.cf``

2. Ajoutez dans le fichier:

   ::

       submission inet n - - - - smtpd
        -o syslog_name=postfix/submission
        -o smtpd_tls_security_level=encrypt
        -o smtpd_sasl_auth_enable=yes
        -o smtpd_client_restrictions=permit_sasl_authenticated,reject

       smtps inet n - - - - smtpd
        -o syslog_name=postfix/smtps
        -o smtpd_tls_wrappermode=yes
        -o smtpd_sasl_auth_enable=yes
        -o smtpd_client_restrictions=permit_sasl_authenticated,reject

3. Sauvegardez et relancez Postfix: ``systemctl restart postfix``

Configuration de MariaDB
~~~~~~~~~~~~~~~~~~~~~~~~

1.  Sécurisez votre installation MariaDB. Tapez :

    .. code:: bash

        mysql_secure_installation.

    Répondez au questions ainsi:

    a. ``Enter current password for root``: ← Tapez Entrée

    b. ``Set root password? [Y/n]``: ← Tapez ``Y``

    c. ``New password:``: ← Tapez votre mot de passe root MariaDB

    d. ``Re-enter New password:``: ← Tapez votre mot de passe root
       MariaDB

    e. ``Remove anonymous users? [Y/n]``: ← Tapez ``Y``

    f. ``Disallow root login remotely? [Y/n]``: ← Tapez ``Y``

    g. ``Remove test database and access to it? [Y/n]``: ← Tapez ``Y``

    h. ``Reload privilege tables now? [Y/n]``: ← Tapez ``Y``

2.  MariaDB doit pouvoir être atteint par toutes les interfaces et pas
    seulement localhost.

3.  Éditez le fichier de configuration. :

    .. code:: bash

        vi /etc/mysql/mariadb.conf.d/50-server.cnf

4.  Commentez la ligne ``bind-address``:
    ``#bind-address           = 127.0.0.1``

5.  Modifiez la méthode d’accès à la base MariaDB pour utiliser la
    méthode de login native.

    a. Tapez :

       .. code:: bash

           echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root

6.  Editez le fichier debian.cnf. Tapez :

    .. code:: bash

        vi /etc/mysql/debian.cnf

    a. Aux deux endroits du fichier ou le mot clé ``password`` est
       présent, mettez le mot de passe root de votre base de données.

    b. ``password = votre_mot_de_passe``

7.  Pour éviter l’erreur ``Error in accept: Too many open files``,
    augmenter la limite du nombre de fichiers ouverts.

    a. Editer le fichier: :

       .. code:: bash

           vi /etc/security/limits.conf

    b. Ajoutez à la fin du fichier les deux lignes:

       .. code:: bash

           mysql soft nofile 65535
           mysql hard nofile 65535

8.  Créez ensuite un nouveau répertoire. Tapez:

    .. code:: bash

        mkdir -p /etc/systemd/system/mysql.service.d/

    a. Editer le fichier limits.conf. :

       .. code:: bash

           vi /etc/systemd/system/mysql.service.d/limits.conf

    b. Ajoutez dans le fichier les lignes suivantes:

       ::

           [Service]
           LimitNOFILE=infinity

9.  Redémarrez votre serveur MariaDB. Tapez: :

    .. code:: bash

        systemctl daemon-reload
        systemctl restart mariadb

10. vérifiez maintenant que MariaDB est accessible sur toutes les
    interfaces réseau. Tapez :

    .. code:: bash

        netstat -tap | grep mysql

11. La sortie doit être du type:
    ``tcp6 0 0 [::]:mysql [::]:* LISTEN 13708/mysqld``

12. Désactiver SpamAssassin puisque amavisd utilise celui ci en sous
    jacent. Tapez :

    .. code:: bash

        systemctl stop spamassassin
        systemctl disable spamassassin.

Configuration d’Apache
~~~~~~~~~~~~~~~~~~~~~~

1. Installez les modules Apache nécessaires. Tapez :

   .. code:: bash

       a2enmod suexec rewrite ssl proxy_http actions include dav_fs dav auth_digest cgi headers actions proxy_fcgi alias.

2. Pour ne pas être confronté aux problèmes de sécurité de type
   `HTTPOXY <https://www.howtoforge.com/tutorial/httpoxy-protect-your-server/>`__,
   il est nécessaire de créer un petit module dans apache.

   a. Éditez le fichier httpoxy.conf: :

      .. code:: bash

          vi /etc/apache2/conf-available/httpoxy.conf

   b. Collez les lignes suivantes:

      .. code:: apache

          <IfModule mod_headers.c>
              RequestHeader unset Proxy early
          </IfModule>

3. Activez le module en tapant :

   .. code:: bash

       a2enconf httpoxy
       systemctl restart apache2

Installation et Configuration de Mailman
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Tapez :

   .. code:: bash

       apt-get install mailman

2. Sélectionnez un langage:

   a. ``Languages to support:`` ← Tapez ``en (English)``

   b. ``Missing site list :`` ← Tapez ``Ok``

3. Créez une mailing list. Tapez: ``newlist mailman``

4. ensuite éditez le fichier aliases: :

   .. code:: bash

       vi /etc/aliases

   et ajoutez les lignes affichées à l’écran:

   ::

       ## mailman mailing list
       mailman:              "|/var/lib/mailman/mail/mailman post mailman"
       mailman-admin:        "|/var/lib/mailman/mail/mailman admin mailman"
       mailman-bounces:      "|/var/lib/mailman/mail/mailman bounces mailman"
       mailman-confirm:      "|/var/lib/mailman/mail/mailman confirm mailman"
       mailman-join:         "|/var/lib/mailman/mail/mailman join mailman"
       mailman-leave:        "|/var/lib/mailman/mail/mailman leave mailman"
       mailman-owner:        "|/var/lib/mailman/mail/mailman owner mailman"
       mailman-request:      "|/var/lib/mailman/mail/mailman request mailman"
       mailman-subscribe:    "|/var/lib/mailman/mail/mailman subscribe mailman"
       mailman-unsubscribe:  "|/var/lib/mailman/mail/mailman unsubscribe mailman"

5. Exécutez :

   .. code:: bash

       newaliases

   et redémarrez postfix: :

   .. code:: bash

       systemctl restart postfix

6. Activez la page web de mailman dans apache: :

   .. code:: bash

       ln -s /etc/mailman/apache.conf /etc/apache2/conf-enabled/mailman.conf

7. Redémarrez apache :

   .. code:: bash

       systemctl restart apache2

   puis redémarrez le demon mailman :

   .. code:: bash

       systemctl restart mailman

8. Le site web de mailman est accessible

   a. Vous pouvez accéder à la page admin Mailman à
      `http://<server1.example.com>/cgi-bin/mailman/admin/ <http://<server1.example.com>/cgi-bin/mailman/admin/>`__

   b. La page web utilisateur de la mailing list est accessible ici
      `http://<server1.example.com/cgi-bin>/mailman/listinfo/ <http://<server1.example.com/cgi-bin>/mailman/listinfo/>`__.

   c. Sous
      `http://<server1.example.com>/pipermail/mailman <http://<server1.example.com>/pipermail/mailman>`__
      vous avez accès aux archives.

Configuration d' Awstats
~~~~~~~~~~~~~~~~~~~~~~~~

1. configurer la tache cron d’awstats: Éditez le fichier :

   .. code:: bash

       vi /etc/cron.d/awstats:

   Et commentez toutes les lignes:

   ::

       #MAILTO=root
       #*/10 * * * * www-data [ -x /usr/share/awstats/tools/update.sh ] && /usr/share/awstats/tools/update.sh
       # Generate static reports:
       #10 03 * * * www-data [ -x /usr/share/awstats/tools/buildstatic.sh ] && /usr/share/awstats/tools/buildstatic.sh

Configuration de Fail2ban
~~~~~~~~~~~~~~~~~~~~~~~~~

1. Editez le fichier: :

   .. code:: bash

       vi /etc/fail2ban/jail.local.

   Ajoutez les lignes suivantes:

   .. code:: ini

       [dovecot]
       enabled = true
       filter = dovecot
       logpath = /var/log/mail.log
       maxretry = 5

       [postfix-sasl]
       enabled = true
       port = smtp
       filter = postfix[mode=auth]
       logpath = /var/log/mail.log
       maxretry = 3

2. Redémarrez Fail2ban: :

   .. code:: bash

       systemctl restart fail2ban

Installation et configuration de PureFTPd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Tapez: :

   .. code:: bash

       apt-get install pure-ftpd-common pure-ftpd-mysql

2. Éditez le fichier de conf: :

   .. code:: bash

       vi /etc/default/pure-ftpd-common

3. Changez les lignes ainsi: ``STANDALONE_OR_INETD=standalone`` et
   ``VIRTUALCHROOT=true``

4. Autorisez les connexions TLS. Tapez:

   .. code:: bash

       echo 1 > /etc/pure-ftpd/conf/TLS

5. Créez un certificat SSL.

   a. Tapez :

      .. code:: bash

          mkdir -p /etc/ssl/private/

   b. Puis créez le certificat auto signé. Tapez :

      .. code:: bash

          openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem

      et répondez aux questions de la manière suivante:

      i.   ``Country Name (2 letter code) [AU]:`` ← Entrez le code pays
           à 2 lettres

      ii.  ``State or Province Name (full name) [Some-State]:`` ← Entrer
           le nom d’état

      iii. ``Locality Name (eg, city) []:`` ← Entrer votre ville

      iv.  ``Organization Name (eg, company) [Internet Widgits Pty Ltd]:``
           ← Entrez votre entreprise ou tapez entrée

      v.   ``Organizational Unit Name (eg, section) []:`` ← Tapez entrée

      vi.  ``Common Name (e.g. server FQDN or YOUR name) []:`` ← Enter
           le nom d’hôte de votre serveur. Dans notre cas:
           server1.example.com

      vii. ``Email Address []:`` ← Tapez entrée

   c. Puis tapez :

      .. code:: bash

          chmod 600 /etc/ssl/private/pure-ftpd.pem

   d. et redémarrez pure-ftpd en tapant: :

      .. code:: bash

          systemctl restart pure-ftpd-mysql

Installation et configuration de phpmyadmin
-------------------------------------------

1. Installez phpmyadmin. Exécutez:

   .. code:: bash

       mkdir /usr/share/phpmyadmin
       mkdir /etc/phpmyadmin
       mkdir -p /var/lib/phpmyadmin/tmp
       chown -R www-data:www-data /var/lib/phpmyadmin
       touch /etc/phpmyadmin/htpasswd.setup
       cd /tmp
       wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
       tar xfz phpMyAdmin-4.9.0.1-all-languages.tar.gz
       mv phpMyAdmin-4.9.0.1-all-languages/* /usr/share/phpmyadmin/
       rm phpMyAdmin-4.9.0.1-all-languages.tar.gz
       rm -rf phpMyAdmin-4.9.0.1-all-languages
       cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php

2. Éditez le fichier :

   .. code:: bash

       vi /usr/share/phpmyadmin/config.inc.php

   a. Modifier l’entrée ``blowfish_secret`` en ajoutant votre propre
      chaîne de 32 caractères.

   b. Éditez le fichier: :

      .. code:: bash

          vi /etc/apache2/conf-available/phpmyadmin.conf

   c. Ajoutez les lignes suivantes:

      .. code:: apache

          # phpMyAdmin default Apache configuration

          Alias /phpmyadmin /usr/share/phpmyadmin

          <Directory /usr/share/phpmyadmin>
           Options FollowSymLinks
           DirectoryIndex index.php

           <IfModule mod_php7.c>
           AddType application/x-httpd-php .php

           php_flag magic_quotes_gpc Off
           php_flag track_vars On
           php_flag register_globals Off
           php_value include_path .
           </IfModule>

          </Directory>

          # Authorize for setup
          <Directory /usr/share/phpmyadmin/setup>
           <IfModule mod_authn_file.c>
           AuthType Basic
           AuthName "phpMyAdmin Setup"
           AuthUserFile /etc/phpmyadmin/htpasswd.setup
           </IfModule>
           Require valid-user
          </Directory>

          # Disallow web access to directories that don't need it
          <Directory /usr/share/phpmyadmin/libraries>
           Order Deny,Allow
           Deny from All
          </Directory>
          <Directory /usr/share/phpmyadmin/setup/lib>
           Order Deny,Allow
           Deny from All
          </Directory>

3. Activez le module et redémarrez apache. Tapez :

   .. code:: bash

       a2enconf phpmyadmin
       systemctl restart apache2

4. Créer la base de donnée phpmyadmin.

   a. Tapez :

      .. code:: bash

          mysql -u root -p.

      puis entrer le mot de passe root

   b. Créez une base phpmyadmin. Tapez :

      .. code:: bash

          CREATE DATABASE phpmyadmin;

   c. Créez un utilisateur phpmyadmin. Tapez :

      .. code:: bash

          CREATE USER 'pma'@'localhost' IDENTIFIED BY 'mypassword'; 

      -  ``mypassword`` doit être remplacé par un mot de passe choisi.

   d. Accordez des privilèges et sauvez:
      ``GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY 'mypassword' WITH GRANT OPTION;``
      puis tapez ``FLUSH PRIVILEGES;`` et enfin ``EXIT;``

5. Chargez les tables sql dans la base phpmyadmin:
   ``mysql -u root -p phpmyadmin < /usr/share/phpmyadmin/sql/create_tables.sql``

6. Enfin ajoutez les mots de passe nécessaires dans le fichier de
   config.

   a. Tapez: ``vi /usr/share/phpmyadmin/config.inc.php``

   b. Rechercher le texte contenant ``controlhost`` . Ci-dessous, un
      exemple:

      .. code:: php

          /* User used to manipulate with storage */
          $cfg['Servers'][$i]['controlhost'] = 'localhost';
          $cfg['Servers'][$i]['controlport'] = '';
          $cfg['Servers'][$i]['controluser'] = 'pma';
          $cfg['Servers'][$i]['controlpass'] = 'mypassword'; 


          /* Storage database and tables */
          $cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';
          $cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
          $cfg['Servers'][$i]['relation'] = 'pma__relation';
          $cfg['Servers'][$i]['table_info'] = 'pma__table_info';
          $cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
          $cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
          $cfg['Servers'][$i]['column_info'] = 'pma__column_info';
          $cfg['Servers'][$i]['history'] = 'pma__history';
          $cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
          $cfg['Servers'][$i]['tracking'] = 'pma__tracking';
          $cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
          $cfg['Servers'][$i]['recent'] = 'pma__recent';
          $cfg['Servers'][$i]['favorite'] = 'pma__favorite';
          $cfg['Servers'][$i]['users'] = 'pma__users';
          $cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
          $cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
          $cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
          $cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
          $cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
          $cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';

      -  A tous les endroit ou vous voyez dans le texte ci dessus le mot
         ``mypassword`` mettez celui choisi. N’oubliez pas de
         dé-commenter les lignes.

Installation et configuration de Roundcube
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Tapez:

   .. code:: bash

       apt-get install roundcube roundcube-core roundcube-mysql roundcube-plugins

2. Éditez le fichier php de roundcube: :

   .. code:: bash

       vi /etc/roundcube/config.inc.php

   et définissez les hosts par défaut comme localhost

   .. code:: php

       $config['default_host'] = 'localhost';
       $config['smtp_server'] = 'localhost';

3. Éditez la configuration apache pour roundcube: :

   .. code:: bash

       vi /etc/apache2/conf-enabled/roundcube.conf

   et ajouter au début les lignes suivantes:

   .. code:: apache

       Alias /roundcube /var/lib/roundcube
       Alias /webmail /var/lib/roundcube

4. Redémarrez Apache:

   .. code:: bash

       systemctl reload apache2

Installation et configuration de ISPConfig
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Tapez:

   .. code:: bash

       cd /tmp

2. Cherchez la dernière version d’ISPConfig sur le site
   `ISPConfig <https://www.ispconfig.org/ispconfig/download/>`__

3. Installez cette version en tapant: :

   .. code:: bash

       wget <la_version_a_telecharger>.tar.gz

4. Décompressez la version en tapant: :

   .. code:: bash

       tar xfz <la_version>.tar.gz

5. Enfin allez dans le répertoire d’installation: :

   .. code:: bash

       cd ispconfig3_install/install/

6. Lancez l’installation: :

   .. code:: bash

       php -q install.php

   et répondez aux questions:

   a. ``Select language (en,de) [en]:`` ← Tapez entrée

   b. ``Installation mode (standard,expert) [standard]:`` ← Tapez entrée

   c. ``Full qualified hostname (FQDN) of the server, eg server1.domain.tld [server1.example.com]:``
      ← Tapez entrée

   d. ``MySQL server hostname [localhost]:`` ← Tapez entrée

   e. ``MySQL server port [3306]:`` ← Tapez entrée

   f. ``MySQL root username [root]:`` ← Tapez entrée

   g. ``MySQL root password []:`` ← Enter your MySQL root password

   h. ``MySQL database to create [dbispconfig]:`` ← Tapez entrée

   i. ``MySQL charset [utf8]:`` ← Tapez entrée

   j. ``Country Name (2 letter code) [AU]:`` ← Entrez le code pays à 2
      lettres

   k. ``State or Province Name (full name) [Some-State]:`` ← Entrer le
      nom d’état

   l. ``Locality Name (eg, city) []:`` ← Entrer votre ville

   m. ``Organization Name (eg, company) [Internet Widgits Pty Ltd]:`` ←
      Entrez votre entreprise ou tapez entrée

   n. ``Organizational Unit Name (eg, section) []:`` ← Tapez entrée

   o. ``Common Name (e.g. server FQDN or YOUR name) []:`` ← Enter le nom
      d’hôte de votre serveur. Dans notre cas: server1.example.com

   p. ``Email Address []:`` ← Tapez entrée

   q. ``ISPConfig Port [8080]:`` ← Tapez entrée

   r. ``Admin password [admin]:`` ← Tapez entrée

   s. ``Do you want a secure (SSL) connection to the ISPConfig web interface (y,n) [y]:``
      ←- Tapez entrée

   t. une deuxième série de question du même type est posée répondre de
      la même manière !

7. L’installation est terminée. Vous accédez au serveur à l’adresse:
   `https://<server1.example.com>:8080/ <https://<server1.example.com>:8080/>`__

       **Note**

       Lors de votre première connexion, votre domaine n’est pas encore
       configuré. Il faudra alors utiliser le nom DNS donné par votre
       hébergeur. Pour OVH, elle s’écrit VPSxxxxxx.ovh.net

8. Loguez vous comme admin et avec le mot de passe que vous avez choisi.
   Vous pouvez décider de le changer au premier login

   a. Si le message "Possible attack detected. This action has been
      logged.". Cela signifie que vous avez des cookies d’une précédent
      installation qui sont configurés. Effacer les cookies de ce site
      de votre navigateur.

Configuration de Let’s Encrypt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Installez Let’s Encrypt. Tapez:

   .. code:: bash

       cd /usr/local/bin
       wget https://dl.eff.org/certbot-auto
       chmod a+x certbot-auto
       ./certbot-auto --install-only

2. Créer votre premier domaine avec SSL et let’s encrypt dans ISPConfig.

3. Liez le certificat d’ISPconfig avec celui du domaine crée:

   a. Tapez :

      .. code:: bash

          cd /usr/local/ispconfig/interface/ssl/
          mv ispserver.crt ispserver.crt-$(date +"%y%m%d%H%M%S").bak
          mv ispserver.key ispserver.key-$(date +"%y%m%d%H%M%S").bak
          ln -s /etc/letsencrypt/live/<example.com>/fullchain.pem ispserver.crt 
          ln -s /etc/letsencrypt/live/<example.com>/privkey.pem ispserver.key 
          cat ispserver.{key,crt} > ispserver.pem
          chmod 600 ispserver.pem
          systemctl restart apache2

      -  remplacer <example.com> par votre nom de domaine

4. Liez le certificat Postfix avec celui de let’s encrypt

   a. Tapez :

      .. code:: bash

          cd /etc/postfix/
          mv smtpd.cert smtpd.cert-$(date +"%y%m%d%H%M%S").bak
          mv smtpd.key smtpd.key-$(date +"%y%m%d%H%M%S").bak
          ln -s /usr/local/ispconfig/interface/ssl/ispserver.crt smtpd.cert
          ln -s /usr/local/ispconfig/interface/ssl/ispserver.key smtpd.key
          service postfix restart
          service dovecot restart

5. Https pour Pureftd

   a. Tapez :

      .. code:: bash

          cd /etc/ssl/private/
          mv pure-ftpd.pem pure-ftpd.pem-$(date +"%y%m%d%H%M%S").bak
          ln -s /usr/local/ispconfig/interface/ssl/ispserver.pem pure-ftpd.pem
          chmod 600 pure-ftpd.pem
          service pure-ftpd-mysql restart

6. Pour Monit:

   a. Editez Monitrc: :

      .. code:: bash

          vi  /etc/monit/monitrc

   b. Ajoutez les lignes suivantes:

      .. code:: ini

          set httpd port 2812 and
          SSL ENABLE
          PEMFILE /etc/ssl/private/pure-ftpd.pem
          allow admin:'secretpassword'

   c. Tapez :

      .. code:: bash

          service monit restart

7. Création d’un script de renouvellement automatique du fichier pem

   a. Installez incron. Tapez :

      .. code:: bash

          apt install -y incron

   b. Créez le fichier d’exécution périodique. Tapez :

      .. code:: bash

          vi /etc/init.d/le_ispc_pem.sh

      et coller dans le fichier le code suivant:

      .. code:: bash

          #!/bin/sh
          ### BEGIN INIT INFO
          # Provides: LE ISPSERVER.PEM AUTO UPDATER
          # Required-Start: $local_fs $network
          # Required-Stop: $local_fs
          # Default-Start: 2 3 4 5
          # Default-Stop: 0 1 6
          # Short-Description: LE ISPSERVER.PEM AUTO UPDATER
          # Description: Update ispserver.pem automatically after ISPC LE SSL certs are renewed.
          ### END INIT INFO
          cd /usr/local/ispconfig/interface/ssl/
          mv ispserver.pem ispserver.pem-$(date +"%y%m%d%H%M%S").bak
          cat ispserver.{key,crt} > ispserver.pem
          chmod 600 ispserver.pem
          chmod 600 /etc/ssl/private/pure-ftpd.pem
          service pure-ftpd-mysql restart
          service monit restart
          service postfix restart
          service dovecot restart
          service nginx restart

   c. Sauvez et quittez. Tapez ensuite:

      .. code:: bash

          chmod +x /etc/init.d/le_ispc_pem.sh
          echo "root" >> /etc/incron.allow
          incrontab -e.

      et ajoutez les lignes ci dessous dans le fichier:

      .. code:: bash

          /etc/letsencrypt/archive/$(hostname -f)/ IN_MODIFY ./etc/init.d/le_ispc_pem.sh

Installation d’un scanner de vulnérabilités
-------------------------------------------

1. installer Git. Tapez :

   .. code:: bash

       apt install git

2. installer Lynis

   a. Tapez :

      .. code:: bash

          git clone https://github.com/CISOfy/lynis

   b. Executez :

      .. code:: bash

          cd lynis;./lynis audit system

3. L’outil vous listera dans une forme très synthétique la liste des
   vulnérabilités et des améliorations de sécurité à appliquer.

Installation de Webmin
----------------------

Webmin est un outil généraliste de configuration de votre serveur. Son
usage peut être assez complexe mais il permet une configuration plus
précise des fonctionnalités.

1.  Se logger ``root`` sur le serveur

2.  Ajoutez le repository Webmin

    a. allez dans le répertoire des repositories. Tapez :

       .. code:: bash

           cd /etc/apt/sources.list.d

    b. Tapez: :

       .. code:: bash

           echo "deb http://download.webmin.com/download/repository sarge contrib" >> webmin.list

    c. Ajoutez la clé. Tapez :

       .. code:: bash

           curl -fsSL http://www.webmin.com/jcameron-key.asc | sudo apt-key add -.

       Le message ``OK`` s’affiche

3.  Mise à jour. Tapez :

    .. code:: bash

        apt update

4.  Installation de Webmin. Tapez :

    .. code:: bash

        apt install Webmin

5.  Autorisation de Webmin au niveau du firewall

    a. Loguez vous Admin sur le site Hestia:
       `https://<example.com>:8083 <https://<example.com>:8083>`__

    b. Allez dans Server→Firewall, puis Add Rule

    c. Sélectionnez Action: ``Allow``, Protocol: ``TCP``, Port:
       ``10000``, IP Address: ``0.0.0.0/0``, Service: ``WEBMIN``

    d. Cliquez sur Save, puis Back

    e. Constatez que le service Webmin sur le port 10000 est autorisé

6.  Connectez vous avec votre navigateur sur l’url
    `https://<example.com>:10000 <https://<example.com>:10000>`__. Un
    message indique un problème de sécurité. Cela vient du certificat
    auto-signé. Cliquez sur 'Avancé' puis 'Accepter le risque et
    poursuivre'.

7.  Loguez-vous ``root``. Tapez le mot de passe de ``root``. Le
    dashboard s’affiche.

8.  Restreignez l’adressage IP

    a. Obtenez votre adresse IP en allant par exemples sur le site
       https://www.showmyip.com/

    b. Sur votre URL Webmin ou vous êtes logué, allez dans Webmin→Webmin
       Configuration

    c. Dans l’écran choisir l’icône ``Ip Access Control``.

    d. Choisissez ``Only allow from listed addresses``

    e. Puis dans le champ ``Allowed IP addresses`` tapez votre adresse
       IP récupérée sur showmyip

    f. Cliquez sur ``Save``

    g. Vous devriez avoir une brève déconnexion le temps que le serveur
       Webmin redémarre puis une reconnexion.

9.  Si vous n’arrivez pas à vous reconnecter c’est que l’adresse IP
    n’est pas la bonne. Le seul moyen de se reconnecter est de:

    a. Loguez vous ``root`` sur serveur

    b. Éditez le fichier /etc/webmin/miniserv.conf et supprimez la ligne
       ``allow= …​``

    c. Tapez :

       .. code:: bash

           service webmin restart

    d. Connectez vous sur l’url de votre site Webmin. Tout doit
       fonctionner

10. Passez en Français. Pour les personnes non anglophone. Les
    traductions française ont des problèmes d’encodage de caractère ce
    n’est donc pas recommandé. La suite de mon tutoriel suppose que vous
    êtes resté en anglais.

    a. Sur votre url Webmin ou vous êtes logué, allez dans Webmin→Webmin
       Configuration

    b. Dans l’écran choisir l’icône ``Language and Locale``.

    c. Choisir ``Display Language`` à ``French (FR.UTF-8)``

Installer quelques outils Debian
================================

Installer l’outil debfoster
---------------------------

L’outil ``debfoster`` permet de ne conserver que les paquets essentiels.
Il maintient un fichier ``keepers`` présent dans ``/var/lib/debfoster``

En répondant aux questions de conservations de paquets, ``debfoster``
maintient la liste des paquets uniques nécessaires au système. Tous les
autres paquets seront supprimés.

1. Se loguer ``root`` sur le serveur

2. Ajouter le paquet ``debfoster``. Tapez :

   .. code:: bash

       apt install debfoster

3. Lancez debfoster. Tapez ``debfoster``.

4. Répondez au questions pour chaque paquet

5. Acceptez la liste des modifications proposées à la fin. Les paquets
   superflus seront supprimés

Installer l’outil dselect
-------------------------

L’outil ``dselect`` permet de choisir de façon interactive les paquets
que l’on souhaite installer.

1. Se loguer ``root`` sur le serveur

2. Ajouter le paquet ``deselect``. Tapez :

   .. code:: bash

       apt install deselect

.. |badge| image:: data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iODYiIGhlaWdodD0iMjAiPjxsaW5lYXJHcmFkaWVudCBpZD0iYiIgeDI9IjAiIHkyPSIxMDAlIj48c3RvcCBvZmZzZXQ9IjAiIHN0b3AtY29sb3I9IiNiYmIiIHN0b3Atb3BhY2l0eT0iLjEiLz48c3RvcCBvZmZzZXQ9IjEiIHN0b3Atb3BhY2l0eT0iLjEiLz48L2xpbmVhckdyYWRpZW50PjxjbGlwUGF0aCBpZD0iYSI+PHJlY3Qgd2lkdGg9Ijg2IiBoZWlnaHQ9IjIwIiByeD0iMyIgZmlsbD0iI2ZmZiIvPjwvY2xpcFBhdGg+PGcgY2xpcC1wYXRoPSJ1cmwoI2EpIj48cGF0aCBmaWxsPSIjNTU1IiBkPSJNMCAwaDM1djIwSDB6Ii8+PHBhdGggZmlsbD0iIzRjMSIgZD0iTTM1IDBoNTF2MjBIMzV6Ii8+PHBhdGggZmlsbD0idXJsKCNiKSIgZD0iTTAgMGg4NnYyMEgweiIvPjwvZz48ZyBmaWxsPSIjZmZmIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LWZhbWlseT0iRGVqYVZ1IFNhbnMsVmVyZGFuYSxHZW5ldmEsc2Fucy1zZXJpZiIgZm9udC1zaXplPSIxMTAiPjx0ZXh0IHg9IjE4NSIgeT0iMTUwIiBmaWxsPSIjMDEwMTAxIiBmaWxsLW9wYWNpdHk9Ii4zIiB0cmFuc2Zvcm09InNjYWxlKC4xKSIgdGV4dExlbmd0aD0iMjUwIj5kb2NzPC90ZXh0Pjx0ZXh0IHg9IjE4NSIgeT0iMTQwIiB0cmFuc2Zvcm09InNjYWxlKC4xKSIgdGV4dExlbmd0aD0iMjUwIj5kb2NzPC90ZXh0Pjx0ZXh0IHg9IjU5NSIgeT0iMTUwIiBmaWxsPSIjMDEwMTAxIiBmaWxsLW9wYWNpdHk9Ii4zIiB0cmFuc2Zvcm09InNjYWxlKC4xKSIgdGV4dExlbmd0aD0iNDEwIj5wYXNzaW5nPC90ZXh0Pjx0ZXh0IHg9IjU5NSIgeT0iMTQwIiB0cmFuc2Zvcm09InNjYWxlKC4xKSIgdGV4dExlbmd0aD0iNDEwIj5wYXNzaW5nPC90ZXh0PjwvZz4gPC9zdmc+

