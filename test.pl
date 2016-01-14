#!/usr/bin/perl

open(FIC, "copie_fichier/passwd") or die "open : $!";
while(<FIC>) {
  my @liste = split(':');
  if ($liste[0] eq "fevrer") {
    print $liste[5],"\n";
    last;
  }
}
close(FIC);
