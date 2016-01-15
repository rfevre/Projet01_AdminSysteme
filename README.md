# Projet01 Administration Systeme
## FEVRE Rémy

---

### Fonctionnalités :

- [x] Ajouter un ou des utilisateurs
- [x] Supprimer un ou des utilisateurs
- [x] Modifier les données des utilisateurs
  - [x] Mot de passe
  - [x] Répertoire de travail
  - [x] Langage de commande
- [ ] Commande help
- [ ] Commande dry-run

---

### Documentation utilisateur :

- #### Ajouter un utilisateur :

  Pour ajouter un utilisateur en ligne de commande

  - `perl outilsAdministration.pl -a <utilisateur> <repertoire_de_travail>`

  - `perl outilsAdministration.pl --ajouter <utilisateur> <repertoire_de_travail>`

  Pour ajouter un ou des utilisateurs grâce à un fichier

  - `perl outilsAdministration.pl -af <chemin_fichier>`

  - `perl outilsAdministration.pl --ajouterParFichier <chemin_fichier>`

- #### Supprimer un utilisateur :

  Pour supprimer un utilisateur en ligne de commande

  - `perl outilsAdministration.pl -s <utilisateur>`

  - `perl outilsAdministration.pl --supprimer <utilisateur>`

  Pour supprimer un ou des utilisateurs grâce à un fichier

  - `perl outilsAdministration.pl -sf <chemin_fichier>`

  - `perl outilsAdministration.pl --supprimerParFichier <chemin_fichier>`

- #### Modifier un utilisateur :

  Pour modifier un utilisateur en ligne de commande

  - `perl outilsAdministration.pl -m <utilisateur> <mot_de_passe:repertoire_de_travail:shell>`

  - `perl outilsAdministration.pl --modifier <utilisateur> <mot_de_passe:repertoire_de_travail:shell>`

  Pour modifier un ou des utilisateurs grâce à un fichier

  - `perl outilsAdministration.pl -mf <chemin_fichier>`

  - `perl outilsAdministration.pl --modifierParFichier <chemin_fichier>`

---

### Documentation technique :

- #### Ajouter un utilisateur :

- #### Supprimer un utilisateur :

- #### Modifier un utilisateur :
