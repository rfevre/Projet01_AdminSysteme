#!/usr/bin/perl

$group="/etc/group";
$shadow="/etc/shadow";
$passwd="/etc/passwd";

$UID = 1000;
$GID = 1000;

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
    ajoutDansDroup($mapUtilisateur);

    # Création du répertoire personnalisé
    creationRepertoire($mapUtilisateur);

    # Mise en place des fichiers d'initialisation du shell
    initialisationShell($mapUtilisateur);

    # Attribution des droits
    attibutionDroits($mapUtilisateur);

    # Définir le propriétaire
    definitionProprietaire($mapUtilisateur);

    # Définition du mot de passe
    # definitionMotDePasse($mapUtilisateur);

    print "OK\n";
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
  # Sous la forme "login:mot_de_passe:UID:GID:info_utilisateur:repertoire_perso:shell_de_connexion"
  my $mapUtilisateur = shift();

  $chaineUtilisateur = "$mapUtilisateur->{\"login\"}:";
  $chaineUtilisateur .= "x:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"UID\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"GID\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"infos\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"repPerso\"}:";
  $chaineUtilisateur .= "$mapUtilisateur->{\"shell\"}";

  open(FIC, ">>$passwd") or die "open : $!";
  print FIC $chaineUtilisateur."\n";
  close(FIC);
}

# Ajout du mot de passe dans le fichier shadow
sub ajoutDansShadow {
  # Sous la forme "login:mot_de_passe_crypté:jours_depuis_dernière_modif:nombre_de_jours_entre_2_modif:nombre_de_jours_avant_changement_mdp:nombre_de_jours_avertissement_expiration_mdp:::"
  my $mapUtilisateur = shift();

  # Transformation de seconde en jours du temps passé depuis le 01/01/1970
  my $date = sprintf("%.0f", time/86400 );
  # Cryptage du mot de passe
  my $mdp = crypt($mapUtilisateur->{"mdp"},"\$6\$"."$mapUtilisateur->{\"UID\"}"."\$");

  $chaineMdp = "$mapUtilisateur->{\"login\"}:";
  $chaineMdp .= "$mdp:";
  $chaineMdp .= "$date:";
  $chaineMdp .= "0:";
  $chaineMdp .= "99999:";
  $chaineMdp .= "7:";
  $chaineMdp .= ":";
  $chaineMdp .= ":";
  $chaineMdp .= ":";

  open(FIC, ">>$shadow") or die "open : $!";
  print FIC $chaineMdp."\n";
  close(FIC);
}

# Ecrire entrée dans /etc/group
sub ajoutDansDroup() {
  ## Sous la forme "nom_du_groupe:mot_de_passe:GID:liste_des_utilisateurs"
  my $mapUtilisateur = shift();
  $chaineGroupe = "$mapUtilisateur->{\"login\"}:";
  $chaineGroupe .= "x:";
  $chaineGroupe .= "$mapUtilisateur->{\"GID\"}:";
  $chaineGroupe .= ":";

  open(FIC, ">>$group") or die "open : $!";
  print FIC $chaineGroupe."\n";
  close(FIC);
}

# Création du répertoire personnel
sub creationRepertoire() {
  my $mapUtilisateur = shift();
  my $repertoire = "$mapUtilisateur->{\"repPerso\"}";
  mkdir $repertoire or die "mkdir : $!";
}

# Mise en place des fichiers d'initialisation du shell
sub initialisationShell() {
  my $mapUtilisateur = shift();
  my $repertoire = "$mapUtilisateur->{\"repPerso\"}";
  `cp -v /etc/skel/.* $repertoire`;
}

# Attribution des droits
sub attibutionDroits() {
  my $mapUtilisateur = shift();
  my $repertoire = "$mapUtilisateur->{\"repPerso\"}";
  chmod 0755, $repertoire;
}

# Définir le propriétaire
sub definitionProprietaire() {
  my $mapUtilisateur = shift();
  my $uid = "$mapUtilisateur->{\"UID\"}";
  my $gid = "$mapUtilisateur->{\"GID\"}";
  my $repertoire = "$mapUtilisateur->{\"repPerso\"}";
  chown $uid, $gid, $repertoire;
}

# Définition du mot de passe
sub definitionMotDePasse() {
  my $mapUtilisateur = shift();
  my $login = "$mapUtilisateur->{\"login\"}";
  `passwd $login`;
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
