#!/usr/bin/perl

  my $mdp = crypt($mapUtilisateur->{"mdp"},"\$6\$"."saltsalt"."\$");

print $mdp,"\n";
