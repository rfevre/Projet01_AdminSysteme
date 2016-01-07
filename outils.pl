
#!/usr/bin/perl

$group="./copie_fichier/group";
$shadow="./copie_fichier/shadow";
$passwd="./copie_fichier/passwd";

checkParameter();

# Verifie les paramétres
sub checkParameter {
  die "Parametres : ajout/suppr/modif ou option --help/-h et --dry-run/-n\n" if @ARGV != 1;

  if ($ARGV[0] eq "ajout")
  {
    my $cpt=1;
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
  # Récupération de la hashmap avec tout les utilisateur à ajouter
  my @tableauUtilisateur = recupInfosUtilisateur(shift());

  print @tableauUtilisateur, "\n";
}

# Récupére une hashmap avec toute les infos du ou des utilisateur(s)
sub recupInfosUtilisateur {
  my $cpt = shift();
  # Hashmap à renvoyé
  my @tableauUtilisateur = undef;

  for($i=0;$i<$cpt;$i++){
    print "\n\n","Ajout de l'utilisateur numéro :", $i+1,"\n\n";

    # Table de hashage contenant les infos de l'utilisateur
    my %utilisateur = undef;
    print "Nom de compte de l'utilisateur :","\n";
    $utilisateur{"login"}=<STDIN>;
    my $mdp = 0;
    while (true) {
      print "Mot de passe de l'utilisateur :","\n";
      system ("stty -echo");
      $utilisateur{"mdp"}=<STDIN>;
      system ("stty echo");
      print "Retaper le mot de passe de l'utilisateur :","\n";
      system ("stty -echo");
      $mdp=<STDIN>;
      system ("stty echo");
      if ($utilisateur{"mdp"} ne $mdp){
        print "\n\n","Mauvais MDP, veuillez recommencer","\n\n";
        redo;
      }
      else {
        last;
      }
    }
    print "Infos de l'utilisateur :","\n";
    $utilisateur{"infos"}=<STDIN>;
    print "Repertoire personnel de l'utilisateur :","\n";
    $utilisateur{"repPerso"}=<STDIN>;
    print "Shell de l'utilisateur :","\n";
    $utilisateur{"shell"}=<STDIN>;
    $utilisateur{"UID"}=ajoutUID();
    $utilisateur{"GID"}=ajoutGID();

    chomp(%utilisateur);

    $chaineUtilisateur = "$utilisateur{\"login\"}:";
    $chaineUtilisateur .= "$utilisateur{\"mdp\"}:";
    $chaineUtilisateur .= "$utilisateur{\"UID\"}:";
    $chaineUtilisateur .= "$utilisateur{\"GID\"}:";
    $chaineUtilisateur .= "$utilisateur{\"infos\"}:";
    $chaineUtilisateur .= "$utilisateur{\"repPerso\"}:";
    $chaineUtilisateur .= "$utilisateur{\"shell\"}";

    push(@tableauUtilisateur,$chaineUtilisateur);
  }

  return @tableauUtilisateur;
}

sub ajoutUID {
  return "UID";
}

sub ajoutGID {
  return "GID;"
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
