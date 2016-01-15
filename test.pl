#!/usr/bin/perl

my $login = "root";
my $mdp = "test";
my $split = ":";

# On recherche la ligne dans le fichier shadow et on la modifie
open IN, '<', "copie_fichier/shadow" or die "open : $!";
my @contents = <IN>;
close IN;

@ligne = grep /^$login/, @contents;
@ligne = split($split,$ligne[0]);
$ligne[1] = crypt($mdp,'$6$sOmEsAlT');

$ligne = join(":",@ligne);

@contents = grep !/^$login/, @contents;
push (@contents,$ligne);

open OUT, '>', "copie_fichier/shadow" or die "close : $!";
print OUT @contents;
close OUT;
