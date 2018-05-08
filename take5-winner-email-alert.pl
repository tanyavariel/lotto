#!/usr/bin/perl
$td=system("date +%m%d%y");
$gd=system("date +%x");
$tw=system("grep '$gd' take5-MASTER-DB.txt");
print "$gd"
