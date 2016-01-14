#!/usr/bin/perl

use Getopt::Long;
use File::Path qw(make_path remove_tree);

$group="copie_fichier/group";
$shadow="copie_fichier/shadow";
$passwd="copie_fichier/passwd";

$split = ":";
$UID = 1000;
$GID = 1000;

checkParameter();

# Verifie les paramétres
sub checkParameter {
  GetOptions(
  "h|help" => \$help,
  "n|dry-run" => \$dryRun,
  "a" => \$ajout,
  "af" => \$ajoutParFichier,
  "s" => \$suppression,
  "sf" => \$suppressionParFichier,
  "m" => \$modification
  )
  or die ("Incorrect parametre : ajout(-a)/suppr(-s)/modif(-m) ou option --help/-h et --dry-run/-n\n");

  if ($help) {
    print "Il a besoin d'aide","\n";
    exit 1;
  }

  elsif ($dryRun) {
    print "Il a fait un dryRun","\n";
  }

  if ($ajout) {
    my $login = $ARGV[0];
    my $repPerso = "/home/$login";
    $repPerso = $ARGV[1] if ( $ARGV[1] );
    print "Ajout de l'utilisateur $login","\n";
    ajout($login,$repPerso);
    print "Compte utilisateur créé\n";
  }

  elsif ($ajoutParFichier) {
    my $fichier = $ARGV[0];
    if (! -f $ARGV[0]) {
      print "Fichier introuvable","\n";
    }
    else {
      print "Ajout par rapport au fichier : $fichier","\n";
      ajoutParFichier($fichier);
    }
    print "Compte utilisateurs créé\n";
  }

  elsif ($suppression) {
    my $login = $ARGV[0];
    print "suppression de $login","\n";
    suppr($login);
    print "Compte supprimé\n";
  }

  elsif ($suppressionParFichier) {
    my $fichier = $ARGV[0];
    if (! -f $ARGV[0]) {
      print "Fichier introuvable","\n";
    }
    else {
      print "Suppression par rapport au fichier : $fichier","\n";
      suppressionParFichier($fichier);
    }
    print "Compte utilisateurs supprimé\n";
  }

  elsif ($modification) {
    my $login = $ARGV[0];
    print "modification de $login","\n";
  }

  exit 1;
}

# Ajout d'un utilisateur
sub ajout {
  my %mapUtilisateur=undef;

  $mapUtilisateur{"login"}=shift();
  $mapUtilisateur{"repPerso"}=shift();
  $mapUtilisateur{"infos"}="";
  $mapUtilisateur{"shell"}="/bin/bash";
  $mapUtilisateur{"UID"}=recupereUID();
  $mapUtilisateur{"GID"}=recupereGID();

  chomp(%mapUtilisateur);

  # On ajoute l'utilisateur dans le fichier passwd
  ajoutDansPasswd(\%mapUtilisateur);

  # Ecrire entrée dans /etc/shadow
  ajoutDansShadow(\%mapUtilisateur);

  # Ecrire entrée dans /etc/group
  ajoutDansDroup(\%mapUtilisateur);

  # Création du répertoire personnalisé
  creationRepertoire(\%mapUtilisateur);

  # Mise en place des fichiers d'initialisation du shell
  initialisationShell(\%mapUtilisateur);

  # Attribution des droits
  attibutionDroits(\%mapUtilisateur);

  # Définir le propriétaire
  definitionProprietaire(\%mapUtilisateur);

  # Définition du mot de passe
  # definitionMotDePasse(\%mapUtilisateur);
}

sub ajoutParFichier {
  my $fichier = shift();
  my @utilisateur = undef;

  open(FIC, "$fichier") or die "open : $!";
  foreach $ligne (<FIC>) {
    @utilisateur = split($split,$ligne);
    chomp @utilisateur;
    if ($utilisateur[0]) {
      ajout($utilisateur[0],$utilisateur[1]); # login:repertoire
    }
  }
  close(FIC);
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
  $chaineMdp .= "!:";
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
  if (! -d $repertoire) {
    mkdir $repertoire or die "mkdir : $!";
  }
}

# Mise en place des fichiers d'initialisation du shell
sub initialisationShell() {
  my $mapUtilisateur = shift();
  my $repertoire = "$mapUtilisateur->{\"repPerso\"}";
  `cp -v /etc/skel/.bash* $repertoire`;
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
  `passwd $login`; # => a modifié
}

# Suppression d'un utilisateur
sub suppr {
  my $login = shift();
  my $repertoire = recupRepertoire($login);

  supprDansGroup($login);
  supprDansPasswd($login);
  supprDansShadow($login);

  supprRepertoire($repertoire);
}

sub suppressionParFichier {
  my $fichier = shift();

  open(FIC, "$fichier") or die "open : $!";
  foreach $login (<FIC>) {
    chomp $login;
    if ($login) {
      suppr($login);
    }
  }
  close(FIC);
}

# Récupération du répertoire de l'utilisateur
sub recupRepertoire() {
  my $login = shift();
  my $repertoire = undef;

  open(FIC, "$passwd") or die "open : $!";
  while(<FIC>) {
    my @liste = split(':');
    if ($liste[0] eq $login) {
      $repertoire = $liste[5];
      last;
    }
  }
  close(FIC);
  return $repertoire;
}

# suppression de la ligne de l'utilisateur dans le fichier group
sub supprDansGroup {
  my $login = shift();
  trouverLigne($group, $login);
}

# suppression de la ligne de l'utilisateur dans le fichier passwd
sub supprDansPasswd {
  my $login = shift();
  trouverLigne($passwd, $login);
}

# suppression de la ligne de l'utilisateur dans le fichier shadow
sub supprDansShadow {
  my $login = shift();
  trouverLigne($shadow, $login);
}

sub trouverLigne {
  my $fichier = shift();
  my $login = shift();

  open IN, '<', $fichier or die "open : $!";
  my @contents = <IN>;
  close IN;

  @contents = grep !/^$login/, @contents;

  open OUT, '>', $fichier or die "close : $!";
  print OUT @contents;
  close OUT;
}

# suppression du repertoire de l'utilisateur
sub supprRepertoire {
  $repertoire = shift();
  if(-e $repertoire)
  {
    remove_tree($repertoire) or die "remove_tree : $!";
  }
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
