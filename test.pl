#!/usr/bin/perl

$mdp = crypt("password",'$6$saltsalt$');
print $mdp,"\n";
