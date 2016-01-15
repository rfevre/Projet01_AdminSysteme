# Projet01 Administration Systeme
## Par FEVRE Rémy - DA2I 2015/2016

---

### Fonctionnalités :

- [x] Ajouter utilisateur
  - [x] Par ligne de commande
  - [x] Par un fichier
- [x] Supprimer un ou des utilisateurs
  - [x] Par ligne de commande
  - [x] Par un fichier
- [x] Modifier les données des utilisateurs (mot de passe, repertoire de travail, langage de commande)
  - [x] Par ligne de commande
  - [x] Par un fichier
- [x] Commande help
- [x] Commande dry-run

---

### Documentation utilisateur :

- #### Ajouter un utilisateur :

  Il n'est pas indispensable de définir un repertoire de travail pour chaque utilisateur car par défaut, si aucun repertoire de travail n'est spécifié, les utilisateurs auront leurs dossiers personnel créer dans **/home/** sous la forme suivante **/home/"login_utilisateur"**.

  Pour ajouter un utilisateur en ligne de commande :

    - `perl adminSys.pl -a <login_utilisateur> <repertoire_de_travail>`

    - `perl adminSys.pl --ajouter <login_utilisateur> <repertoire_de_travail>`

  Pour ajouter un ou des utilisateurs grâce à un fichier :

  (format du fichier par ligne : *"utilisateur"*:*"repertoire_de_travail"*)

    - `perl adminSys.pl -af <chemin_fichier>`

    - `perl adminSys.pl --ajouterParFichier <chemin_fichier>`

- #### Supprimer un utilisateur :

  Pour supprimer un utilisateur en ligne de commande :

    - `perl adminSys.pl -s <login_utilisateur>`

    - `perl adminSys.pl --supprimer <login_utilisateur>`

  Pour supprimer un ou des utilisateurs grâce à un fichier :

  (format du fichier par ligne : *"utilisateur"*)

    - `perl adminSys.pl -sf <chemin_fichier>`

    - `perl adminSys.pl --supprimerParFichier <chemin_fichier>`

- #### Modifier un utilisateur :

  Le format du paramétre "modification" est le suivant "mot_de_passe:repertoire_de_travail:shell". Les champs ne sont pas tous obligatoires, il est possible de rentrer simplement un mot de passe et de laisser les autres champs vide ("mot_de_passe::").

  Pour modifier un utilisateur en ligne de commande :

    - `perl adminSys.pl -m <login_utilisateur> <modification>`

    - `perl adminSys.pl --modifier <login_utilisateur> <modification>`

  Pour modifier un ou des utilisateurs grâce à un fichier :

  (format du fichier par ligne : *"utilisateur"*;*"mot_de_passe:repertoire_de_travail:shell"* )

    - `perl adminSys.pl -mf <chemin_fichier>`

    - `perl adminSys.pl --modifierParFichier <chemin_fichier>`

---

### Documentation technique :

- #### Ajouter un utilisateur :

- #### Supprimer un utilisateur :

- #### Modifier un utilisateur :
