#!/usr/bin/perl


my $fichier = '/home/fevrer/workspace/AdminSystem/Projet01_AdminSysteme/ajoutFichier.txt';
my @utilisateur = undef;

open(FIC, $fichier) or die "open : $!";
foreach $ligne (<FIC>) {
  @utilisateur = split(":",$ligne);
  chomp @utilisateur;
  if ($utilisateur[0] ne "") {
    print ($utilisateur[0],":",$utilisateur[1],"\n"); # login:repertoire
  }
}
close(FIC);
