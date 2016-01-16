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

Pour utiliser toutes les commandes, vous avez besoin d'être connecté en tant que **root**.

- #### Ajouter un utilisateur :

  Il n'est pas indispensable de définir un repertoire de travail pour chaque utilisateur car par défaut, si aucun repertoire de travail n'est spécifié, les utilisateurs auront leurs dossiers personnel créer dans **/home/** sous la forme suivante **/home/"login_utilisateur"**.

  Le mot de passe par défaut pour se connecter sur l'utilisateur est le suivant : **test** (A modifier à la première connexion de l'utilisateur)

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

Cette documentation s'adresse à toutes personnes capable de comprendre et modifier le fichier **adminSys.pl** écrit en **PERL**.

- #### Variables par défaut :

  Si besoin, les variables suivante peuvent être modifié pour s'ajuster à ce dont vous avez besoin.
    - `$group` => Chemin vers le fichier "group"
    - `$shadow` => Chemin vers le fichier "shadow"
    - `$passwd` => Chemin vers le fichier "passwd"
    - `$fichierHelp` => Chemin vers le fichier d'aide
    - `$mdpDefaut` => Le mot de passe donné aux utilisateurs
    - `$repertoireDefaut` => Repertoire ou enregistrer le repertoire de travail de l'utilisateur
    - `$shellDefaut` => Le shell utilisé
    - `$split` => Le split utilisé pour le format des données
    - `$UID` => UID minimum utilisé
    - `$GID` => GID minimum utilisé

- #### Ajouter un utilisateur :

  Que cela soit par fichier ou par ligne de commande, la fonction d'ajout d'un utilisateur attend un login utilisateur unique et un repertoire de travail, si le repertoire de travail n'est pas spécifié, par défaut il prendra la valeur suivante **$repertoireDefaut/login_utilisateur**.

  `ajout($login,$repPerso)`

  Cette fonction passe par une HashMap pour enregistrer les informations de l'utilisateur. On utilise cette HashMap pour rajouter une ligne dans les fichiers **passwd**, **shadow** et **group** avec le bon format de ligne.

  Ensuite le repertoire de l'utilisateur est créer, on lui attribue les droits nécéssaire et on le définit en tant que propriétaire sur celui-ci, on copie enfin dans ce répertoire les fichiers indispensable à l'initialisation du shell.

  `ajoutParFichier($fichier)`

  Pour chaque ligne du fichier, on appelle la fonction `ajout($login,$repPerso)`

- #### Supprimer un utilisateur :

  Que cela soit par fichier ou par ligne de commande, la fonction de suppression d'un utilisateur attend simplement un login utilisateur.

  `suppr($login)`

  Cette fonction retrouve le repertoire de travail de l'utilisateur grâce à une recherche dans le fichier **passwd** de la ligne ou l'on trouve le login de l'utilisateur envoyé à la fonction, ensuite le repertoire de l'utilisateur peut être supprimé.

  On supprime aussi dans les fichier **group**,**passwd** et **shadow** la ligne de l'utilisateur.

  `suppressionParFichier($fichier)`

  Pour chaque ligne du fichier, on appelle la fonction `suppr($login)`

- #### Modifier un utilisateur :

  Que cela soit par fichier ou par ligne de commande, la fonction de modification d'un utilisateur attend un login utilisateur et une chaine de caractères de la forme suivante **mot_de_passe:repertoire_de_travail:shell**.

  `modif($login,$modification)`

  Cette fonction modifie la ligne de l'utilisateur dans le fichier **shadow** si le mot de passe doit être modifié et dans le fichier **passwd** si le repertoire de travail ou le shell doit être modifié.

  `modificationParFichier($fichier)`

  Pour chaque ligne du fichier, on appelle la fonction `modif($login,$modification)`

- #### Hachage des mots de passe :

  Les mots de passe sont crypté et enregistrer dans le fichier **shadow** grâce à la commande suivante :

  `crypt($mapUtilisateur->{"mdp"},'$6$salt');`

  - $6 => Correspond à un hachage de type SHA-512
  - $salt => Correspond à la clé de hachage

---
