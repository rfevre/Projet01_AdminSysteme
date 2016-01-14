#!/usr/bin/perl


  open(FIC, "/home/infoetu/fevrer/workspace/Admin_Systeme/Projet_1/ajoutFichier.txt") or die "open : $!";
  while(<FIC>) {
    my @utilisateur = split(":");
    if ($utilisateur[0] ne "") {
      chomp($utilisateur[1]);
      print $utilisateur[0]," ",$utilisateur[1],"\n"; # login - repertoire
    }
  }
  close(FIC);
