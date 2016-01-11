
#!/usr/bin/perl

$group="./copie_fichier/group";
$shadow="./copie_fichier/shadow";
$passwd="./copie_fichier/passwd";

$UID = 101;
$GID = 101;

checkParameter();

# Verifie les paramétres
sub checkParameter {
  die "Parametres : ajout/suppr/modif ou option --help/-h et --dry-run/-n\n" if @ARGV < 1;

  if ($ARGV[0] eq "ajout")
  {
    my $cpt=1;
    if ( $ARGV[1] =~ m/^\d+$/ ) {
      $cpt=$ARGV[1];
    }
    ajout($cpt);
  }
  elsif ($ARGV[0] eq "suppr")
  {
    suppr();
  }
  elsif ($ARGV[0] eq "modif")
  {
    modif();
  }
  # A revoir
  elsif ($ARGV[0] eq "--help" || $ARGV[0] eq "-h")
  {
    aide();
  }
  # A revoir
  elsif ($ARGV[0] eq "--dry-run" || $ARGV[0] eq "-n")
  {
    dryRun();
  }
  else
  {
    die "Incorrect parametre : ajout/suppr/modif ou option --help ou -h et --dry-run/-n\n";
  }
}

# Ajout d'un utilisateur
sub ajout {
  my $cpt = shift();
  for($i=0;$i<$cpt;$i++){
    # On récupére la map avec toute les infos de l'utilisateur (map par référence)
    my $mapUtilisateur = recupInfosUtilisateur($i+1);

    # On ajoute l'utilisateur dans le fichier passwd
    ajoutDansPasswd($mapUtilisateur);

    # Ecrire entrée dans /etc/shadow
    ajoutDansShadow($mapUtilisateur);

    # Ecrire entrée dans /etc/group
    ajoutDansDroup();

    # Création du répertoire personnalisé
    creationRepertoire();

    # Mise en place des fichiers d'initialisation du shell
    initialisationShell();

    # Attribution des droits
    attibutionDroits();

    # Définir le propriétaire
    definitionProprietaire();

    # Définition du mot de passe
    definitionMotDePasse();

    # TEST !!!
    print $mapUtilisateur, "\n";
    print $mapUtilisateur->{"mdp"},"\n";
  }

}

# Renvoie une map avec toute les infos de l'utilisateur à créer
sub recupInfosUtilisateur {
  my $cpt = shift();
  my %mapUtilisateur = undef;

  print "Ajout de l'utilisateur numéro :", $cpt,"\n\n";

  print "Nom de compte de l'utilisateur :","\n";
  $mapUtilisateur{"login"}=<STDIN>;

  my $tmp = undef;
  do {
    print "Mot de passe de l'utilisateur :","\n";
    system ("stty -echo");
    $mapUtilisateur{"mdp"}=<STDIN>;
    system ("stty echo");

    print "Retaper le mot de passe de l'utilisateur :","\n";
    system ("stty -echo");
    $tmp=<STDIN>;
    system ("stty echo");

    print "\n","Mauvais mot de passe, veuillez recommencer","\n\n" if ($mapUtilisateur{"mdp"} ne $tmp);

  } while ($mapUtilisateur{"mdp"} ne $tmp);

  print "Infos de l'utilisateur :","\n";
  $mapUtilisateur{"infos"}=<STDIN>;

  print "Repertoire personnel de l'utilisateur :","\n";
  $mapUtilisateur{"repPerso"}=<STDIN>;

  print "Shell de l'utilisateur :","\n";
  $mapUtilisateur{"shell"}=<STDIN>;

  $mapUtilisateur{"UID"}=recupereUID();
  $mapUtilisateur{"GID"}=recupereGID();

  print "\n\n";
  chomp(%mapUtilisateur);

  # On envoie la map par référence
  return \%mapUtilisateur;
}

# Recupere un UID non utilisé dans le fichier passwd
sub recupereUID {
  while(getpwuid($UID))
  {
    $UID++;
  }
  return $UID;
}

# Recupere un GID non utilisé dans le fichier passwd
sub recupereGID {
  while(getgrgid($GID))
  {
    $GID++;
  }
  return $GID;
}

# Ajoute l'utilisateur dans le fichier passwd
sub ajoutDansPasswd {
  my $mapUtilisateur = shift();
  $chaineUtilisateur = "$mapUtilisateur->{\"login\"}:";
  $chaineUtilisateur .= "x:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"UID\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"GID\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"infos\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"repPerso\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"shell\"}";

  ## Sous la forme "login:mot_de_passe:UID:GID:info_utilisateur:repertoire_perso:shell_de_connexion"
  open(FIC, ">>$passwd") or die "open : $!";
  print FIC $chaineUtilisateur."\n";
  close(FIC);
}

# Ajoute du mot de passe dans le fichier shadow
sub ajoutDansShadow {

}

# Ecrire entrée dans /etc/group
sub ajoutDansDroup() {

}

# Création du répertoire personnalisé
sub creationRepertoire() {

}

# Mise en place des fichiers d'initialisation du shell
sub initialisationShell() {

}

# Attribution des droits
sub attibutionDroits() {

}

# Définir le propriétaire
sub definitionProprietaire() {

}

# Définition du mot de passe
sub definitionMotDePasse() {

}

# Suppression d'un utilisateur
sub suppr {

}

# Modification d'un utilisateur
sub modif {

}

# Aide sur les commandes
sub aide {

}

# Permet de voir ce que la commande s'apprête à faire
sub dryRun {

}
