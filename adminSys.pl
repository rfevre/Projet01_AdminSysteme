#!/usr/bin/perl

use Getopt::Long;
use File::Path qw(make_path remove_tree);

$group="/etc/group"; # Chemin du fichier group
$shadow="/etc/shadow"; # Chemin du fichier shadow
$passwd="/etc/passwd"; # Chemin du fichier passwd
$fichierHelp="./help.txt"; # Chemin du fichier d'aide

$mdpDefaut = "test"; # Mot de passe à donner au utilisateurs
$shellDefaut = "/bin/bash"; # Shell à utiliser par défaut
$split = ":"; # Split par défaut
$UID = 1000; # UID minimum
$GID = 1000; # GID minimum

checkParameter();

# Verifie les paramétres
sub checkParameter {
  GetOptions(
  "h|help" => \$help,
  "n|dry-run" => \$dryRun,
  "a|ajouter" => \$ajout,
  "af|ajouterParFichier" => \$ajoutParFichier,
  "s|supprimer" => \$suppression,
  "sf|supprimerParFichier" => \$suppressionParFichier,
  "m|modifier" => \$modification,
  "mf|modifierParFichier" => \$modificationParFichier
  )
  or die ("Parametre(s) incorrect : Pour plus d'informations, lire le fichier README.md\n");

  if ($help) {
    aide();
    exit 1;
  }

  elsif ($dryRun) {
    dryRun(\@ARGV);
    exit 1;
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
      print "Compte utilisateurs créé\n";
    }
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
      print "Compte utilisateurs supprimé","\n";
    }
  }

  elsif ($modification) {
    if ($ARGV[0] && $ARGV[1]) {
      modif($ARGV[0],$ARGV[1]) if ($ARGV[0] && $ARGV[1]);
      print "Compte utilisateur modifié\n";
    }
    else {
      print "Nombre d'arguments incorrect","\n";
    }
  }

  elsif ($modificationParFichier) {
    my $fichier = $ARGV[0];
    if (! -f $ARGV[0]) {
      print "Fichier introuvable","\n";
    }
    else {
      print "Modification par rapport au fichier : $fichier","\n";
      modificationParFichier($fichier);
      print "Compte utilisateurs modifié","\n";
    }
  }

  exit 1;
}

# Ajout d'un utilisateur
sub ajout {
  my %mapUtilisateur=undef;

  $mapUtilisateur{"login"}=shift();
  $mapUtilisateur{"mdp"}=$mdpDefaut;
  $mapUtilisateur{"repPerso"}=shift();
  $mapUtilisateur{"infos"}="";
  $mapUtilisateur{"shell"}=$shellDefaut;
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

}

# Ajout d'un ou plusieurs utilisateurs grâce à un fichier
sub ajoutParFichier {
  # format => login:repertoire
  my $fichier = shift();
  my @utilisateur = undef;
  my $login = undef;
  my $repPerso = undef;

  open(FIC, "$fichier") or die "open : $!";
  foreach $ligne (<FIC>) {
    @utilisateur = split($split,$ligne);
    chomp @utilisateur;
    $login = $utilisateur[0];
    $repPerso = "/home/$login";
    $repPerso = $utilisateur[1] if ($utilisateur[1]);
    if ($login) {
      ajout($login,$repPerso);
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
  my $mdp = crypt($mapUtilisateur->{"mdp"},'$6$sOmEsAlT');

  $chaineMdp = "$mapUtilisateur->{\"login\"}:";
  $chaineMdp .= "$mdp:";
  $chaineMdp .= "$date:";
  $chaineMdp .= "0:";
  $chaineMdp .= "99999:";
  $chaineMdp .= "7:";
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

# Suppression d'un utilisateur
sub suppr {
  my $login = shift();
  my $repertoire = recupRepertoire($login);

  supprDansGroup($login);
  supprDansPasswd($login);
  supprDansShadow($login);

  supprRepertoire($repertoire);
}

# Suppresion d'un ou plusieurs utilisateurs grâce à un fichier
sub suppressionParFichier {
  # format par ligne => login
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

# Récupération du répertoire de l'utilisateur grâce à son login
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

# Suppression de la ligne de l'utilisateur dans le fichier group
sub supprDansGroup {
  my $login = shift();
  trouverLigne($group, $login);
}

# Suppression de la ligne de l'utilisateur dans le fichier passwd
sub supprDansPasswd {
  my $login = shift();
  trouverLigne($passwd, $login);
}

# Suppression de la ligne de l'utilisateur dans le fichier shadow
sub supprDansShadow {
  my $login = shift();
  trouverLigne($shadow, $login);
}

# Permet de trouver la ligne d'informations d'un utilisateur dans les fichiers, grâce à son login
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

# Suppression du repertoire de l'utilisateur
sub supprRepertoire {
  $repertoire = shift();
  if(-e $repertoire)
  {
    remove_tree($repertoire) or die "remove_tree : $!";
  }
}

# Modification d'un utilisateur
sub modif {
  my $login = shift();
  my @ligne = split($split,shift());
  my $mdp = $ligne[0];
  my $repPerso = $ligne[1];
  my $shell = $ligne[2];

  modifShadow($login,$mdp) if ($mdp);
  modifPasswd($login,$repPerso,$shell) if ($repPerso || $shell);
}

# Modification d'un ou plusieurs utilisateurs grâce à un fichier
sub modificationParFichier {
  # format => login:repertoire
  my $fichier = shift();
  my $login = undef;
  my $ligne = undef;
  my @utilisateur = undef;

  open(FIC, "$fichier") or die "open : $!";
  foreach $ligne (<FIC>) {
    @utilisateur = split(";",$ligne);
    chomp @utilisateur;
    $login = $utilisateur[0];
    $ligne = $utilisateur[1];
    if ($login && $ligne) {
      modif($login,$ligne);
    }
  }
  close(FIC);
}

# Modification du mot de passe d'un utilisateur
sub modifShadow {
  my $login = shift();
  my $mdp = shift();

  # On recherche la ligne dans le fichier shadow et on la modifie
  open IN, '<', $shadow or die "open : $!";
  my @contents = <IN>;
  close IN;

  @ligne = grep /^$login/, @contents;
  @ligne = split($split,$ligne[0]);
  $ligne[1] = crypt($mdp,'$6$sOmEsAlT');
  $ligne[2] = sprintf("%.0f", time/86400 );

  $ligne = join(":",@ligne);

  @contents = grep !/^$login/, @contents;
  push (@contents,$ligne);

  open OUT, '>', $shadow or die "close : $!";
  print OUT @contents;
  close OUT;
}

# Modification du repertoire Perso d'un utilisateur
sub modifPasswd {
  my $login = shift();
  my $repPerso = shift();
  my $shell = shift();

  # On recherche la ligne dans le fichier passwd et on la modifie
  open IN, '<', $passwd or die "open : $!";
  my @contents = <IN>;
  close IN;

  @ligne = grep /^$login/, @contents;
  @ligne = split($split,$ligne[0]);
  $ligne[5] = $repPerso if ($repPerso);
  $ligne[6] = $shell if ($shell);

  $ligne = join(":",@ligne);

  @contents = grep !/^$login/, @contents;
  push (@contents,$ligne);

  open OUT, '>', $passwd or die "close : $!";
  print OUT @contents;
  close OUT;
}

# Aide sur les commandes
sub aide {
  open (FIC,"$fichierHelp") or die "open : $!";
  foreach $ligne (<FIC>) {
    print $ligne;
  }
}

# Affiche une courte description de(s) (l')option(s) passé en paramètre(s).
sub dryRun {
  my $tabCommandes = shift();
  foreach $option (@{$tabCommandes}) {
    print $option," : Ajout d'un utilisateur","\n" if ($option eq "a" || $option eq "ajouter");
    print $option," : Ajout d'un ou plusieurs utilisateur(s) par un fichier","\n" if ($option eq "af" || $option eq "ajouterParFichier");
    print $option," : Suppression d'un utilisateur","\n" if ($option eq "s" || $option eq "supprimer");
    print $option," : Suppression d'un ou plusieurs utilisateur(s) par un fichier","\n" if ($option eq "sf" || $option eq "supprimerParFichier");
    print $option," : Modification d'un utilisateur","\n" if ($option eq "m" || $option eq "modifier");
    print $option," : Modification d'un ou plusieurs utilisateur(s) par un fichier","\n" if ($option eq "mf" || $option eq "modifierParFichier");
    print $option," : Permet d'obtenir de l'aide","\n" if ($option eq "h" || $option eq "help");
  }
}
