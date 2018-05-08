#!/usr/bin/perl
#


$debug=0;
$err=0;
$lowest=100;

open(WINS, "number-mega-nums-OK.txt");
while (<WINS>) {
	$lines++; 
}
close(WINS);

print "Getting [$lines] lines\n";

#$wl=int(rand($lines+1)); 
open(WINS, "number-mega-nums-OK.txt");
#open(WINS, "numbers_mega5.txt");
#  open(WINS, "numbers_take5-4.txt");
  foreach ( 1 .. $lines ) {
    $y=<WINS>;
    chop($y);
   print "Got: [$y] - ";
   @winner=split(/,/,$y);
   foreach $n ( 0 .. 4 ) {
	   printf ("Counting [%04d] one more time: [%05d]\n",$winner[$n],$nc[$winner[$n]]);
	   $nc[$winner[$n]]+=1;
	   if ($winner[$n]>$highest) { $highest=$winner[$n]; }
	   if ($winner[$n]<$lowest) {$lowest = $winner[$n]; }
    }
   }
   close(WINS);
   printf ("Lowest number: %03d\n",$lowest);
   printf ("Highest number: %03d\n",$highest);
   foreach $n1 ( $lowest .. $highest ) {
	   #printf ("Frequency of [%02d] = [%03d]\n",$n1,$nc[$n1]);
	   printf ("%02d, %03d\n",$n1,$nc[$n1]);
   }
#}

#
#sub bynumber { $a <=> $b; }
#
#
#sub getgame {
#
#   do {
#   $err=0;
#
#	foreach $i (1 .. $balls) {  #  balls 1 to 5 list of avail numbers
#		$s[$i]=$i;
#		if ($debug>2) { print "s[i]= $s[$i]\n"; }
#	}
#	foreach $i (1 .. $balls) {  # MegaBall
#		$s2[$i]=$i;
#		if ($debug>2) { print "s[i]= $s[$i]\n"; }
#	}
#
#	foreach $r (1 .. $numbers-1 ) {
#		$rn=rand(($balls+1)-$r);
#		# rand from (0..51+1)-(1..5)) 0..52-1=-1..51, 0..52-2=-2..51, 53-3=50, 53-4=49 - how many balls we have to choose from on each draw
#		#print "Got random [$rn]";
#		$k=int($rn);
#		#print "K = [$k]";
#		$k=int($rn)+1;
#		#print "K = [$k] R = [$r]\n";
#		#$k=$k-$r;
#		#print "Know = [$k]\n";
#		#print "---------------\n";
#
#		#$k=int((rand($balls+1)+1)-$r);
#		$n2[$r]=$s[$k]; # choose ball based on $k from list $s
#		if ($debug)  { print "$n2[$r]=$s[$k] - "; }
#		foreach $t ($k .. $balls-$r) { # Here we remove the number we got ($k) from the list $s
#			$s[$t]=$s[$t+1];
#		}
#	}
#
#	$k=int(rand($balls)+1);  # Last Mega-Ball number - rand returns a number >= 0 and less than the value of EXPR
#
#	#$n2[$numbers]=$s[$k];
#	#$n2[$numbers]=$k; # Set it to $k not $s!!!!
#	#if ($debug)  { print "(MegaBall)$n2[$numbers]=[$k]\n"; }
#	
#	$power=$k;
#
#	if ($debug)  { printf ("(MegaBall)[%2d]=[%2d]\n",$power,$k); }
#	
#	#if ($debug)  { print "LOTTO #: "; }
#	@ns = sort bynumber @n2;
#	
#	if ($debug)  { print "SORTED:[@ns] "; }
#	foreach $nf (1 .. $numbers-1) {
#		#$n[$cc][$nf] = $ns[$nf];
#		if ($debug)  { print "$ns[$nf] "; }
#		$sum=$sum+$ns[$nf];
#	}
#	if ($debug) { print "\n"; }
#
#	$ns[$numbers]=$power;
#
#
#	# First Four Digit Sum
#	$ff=0;
#	foreach $w (1 .. 4) {
#		$ff=$ff+$ns[$w];
#	}
#	if ($ff <= $ff_min || $ff >= $ff_max) { $err=1; if (!$debug) { print "ERROR: First Four OUT OF RANGE - "; } }
#	if ($debug) { print "First Four=[$ff] [ff_min=$ff_min ff_max=$ff_max]"; }
#	# Last four digit sum
#	$lf=0;
#	for ( $w=$numbers ;$w > $numbers-4; $w-- ) {
#		$lf=$lf+$ns[$w];
#	}
#	if ($lf <= $lf_min || $lf >= $lf_max) { $err=1; if (!$debug) { print "ERROR: Last Four OUT OF RANGE - "; } }
#	if ($debug) { print "Last Four=[$lf] [lf_min=$lf_min lf_max=$lf_max]\n"; }
#
#	# By ones
##@onerangemin=( 2, 6, 14, 23, 41 );
##@onerangemax=( 18, 32, 43, 49, 52 ); # 52 ball game
#	$hot=0;
#	for ($w = 1; $w < $numbers-1 ; $w++) {
#	    if ( $ns[$w] < $onerangemin[$w-1]  || $ns[$w] > $onerangemax[$w-1] ) { $hot++; }
#        }
#    	if ( $hot > 2 ) {
#	 print "ERROR: Number NOT hot enough! [$hot]\n";
#	    #pnums();
#	    $err=1;
#    	}
#
#	# By Twos
#	#$cnt=0;
#	#for ($w=1; $w < $numbers-1 ; $w++ )  {
##		$bytwos[$w]=$ns[$w]+$ns[$w+1];
##	}
#	#
#	#if ($debug) { 
##		print "SUM=[$sum]  -  1st4[$ff] 2nd4[$lf]\n";
##			print "BYTWOS: ";
##		for ($w = 1; $w < $numbers-1 ; $w++) {
##			print "$bytwos[$w],";
##		}
##			print "\n";
##	}
#		#123456
#		#12
#		# 23
#		#  34
#		#   45
#		#    56
#	
#
#	if ($debug) { print " SUM=[$sum]   -> SUMRANGEMIN:[$sumrangemin] to SUMRANGEMAX:[$sumrangemax]\n"; }
#	if ( $sum < $sumrangemin or $sum > $sumrangemax ) {
#		if (!$debug)  { print "ERROR: SUM Out of range ($sumrangemin to $sumrangemax): $sum\n"; }
#		$err=1;
#	}
##	for ($w = 1; $w < $numbers-1 ; $w++) {
##		if ($debug) {print "CHECK BYTWOS: $bytwos[$w] \n"; }
##			if ($debug)  { print "Bytwos: $bytwos[$w] Checked against $tworangemin[$w] and $tworangemax[$w])\n"; }
##		if ($bytwos[$w] < $tworangemin[$w] or $bytwos[$w] > $tworangemax[$w] ) {
##			if ($debug)  { print "Bytwos: $bytwos[$w] out of range ($tworangemin[$w] and $tworangemax[$w])\n"; }
##			$err=1;
##		}
#	#
#	#}
#
#	if ($debug) { print "ERR[$err] iteration:[$uu < $games]\n";
#		print "\n=================================\n";
#	}
#
#	$sum=0;
#	if ($debug) { sleep (2); }
#   } while ($err>0) # redo on error loop
#
#} # done with Sub getgame
#
#foreach $uu (1 .. $games) {
#	$err=0;
#        if ($debug) { print "Getting Game:[$uu]\n"; }
#	   getgame();
#	   foreach $w (1 .. $numbers-1) {
#	      $yg[$uu][$w]=$ns[$w];
#  	   }
#	   $yg[$uu][$numbers]=$power;
#   	   pnums();
#}
#print "And the WINNER IS.... [";
##getgame();
##@winner=@ns;
##pnums();
## Take FIVE Only
#getwinner();
#print "@winner] - MegaBall=[";
#printf ("%02d  - ",$winner[$numbers-1]);
#
#
#print "SUCKER!!!!\n";
#$winnings=0;
#foreach $uu (1 .. $games) {
#	$hits=0;
#	$hot=0;
#	$megaball=0;
#	printf ("GAME #[%02d]:",$uu);
#	foreach $e ( 1 .. $numbers -1 )  {
#		foreach $q ( 0 .. $numbers -2 ) {
#			$h=0;
#			#printf ("winner[%d]=%02d yg[%d][%d]=%02d : ",$q,$winner[$q],$uu,$e,$yg[$uu][$e]);
#			if ( $winner[$q]==$yg[$uu][$e] ) {
#				#printf ("  -->winner[%d]=%02d yg[%d][%d]=%02d : ",$q,$winner[$q],$uu,$e,$yg[$uu][$e]);
#				$hits++;
#			}
#		}
#		if ( $yg[$uu][$e] < $onerangemin[$e-1]  || $yg[$uu][$e] > $onerangemax[$e-1] ) { $hot++; }
#		printf(" %02d",$yg[$uu][$e]);
#	}
#	if ($winner[$numbers-1] == $yg[$uu][$numbers]) { 
#		printf ("   Mega Ball Hit=%02d",$yg[$uu][$numbers]);
#		$megaball=1;
#	} 
#	else {
#		printf("   Mega Ball NG = %02d",$yg[$uu][$numbers]);
#	}
#	print " HOT=[$hot] --  HITS: $hits MEGABALL=$megaball = ";
#
#	if ($hits == 0 && $megaball >  0 ) { print " - \$2.00 "; $winnings+=2; }
#	if ($hits == 1 && $megaball >  0 ) { print " - \$3.00 "; $winnings+=3; }
#	if ($hits == 2 && $megaball >  0 ) { print " - \$10.00 "; $winnings+=10; }
#	if ($hits == 3 && $megaball == 0 ) { print " - \$7.00 "; $winnings+=7; }
#	if ($hits == 3 && $megaball >  0 ) { print " - \$150.00 "; $winnings+=150; }
#	if ($hits == 4 && $megaball == 0 ) { print " - \$150.00 "; $winnings+=150; }
#	if ($hits == 4 && $megaball >  0 ) { print " - \$5000.00 "; $winnings+=5000; }
#	if ($hits == 5 && $megaball == 0 ) { print " - \$175,000.00 "; $winnings+=175000; }
#	if ($hits == 5 && $megaball >  0 ) { print " - \$121,000,000.00  JACKPOT!!!!!!!!!"; $winnings+=121000000; }
#
#	if ($hits =>1 ) { print "\n"; }
#}
#print "WINNINGS: [$winnings]\n";
#
#
#sub pnums {
#	foreach $q ( 1 .. $numbers -1) {
#		printf ("%02d",$ns[$q]);
#		if ($q < $numbers-1) { print ", "; }
#	}
#	printf (" ---- Mega Ball=[%02d]",$ns[$numbers],$power);
#	print "\n";
#}
#
##if ($forever) {
##		@ww=split(/,/,$y);
##		#print "@ww\n";
##			$c3=0;
##		foreach $op (@ww) {
##			foreach $ty ( 1 .. 6) {
##				if ($n[1][$ty] == $op) {
##					$c3++;
##					$win[$c3]=$n[1][$ty]; 
##					#		print "--C3[$c3] - WIN $win[$c3] - N $n[1][$ty]";
##				}
##			}
##		}
##		if ($c3>$forever) { 
##			print "Iteration[$it]: ";
##			foreach $ry (1 .. $c3) { 
##				print "$win[$ry], "; 
##			}
##			print "\n";
##		}
##	}
##	close(WINS);
##
##}
##
##
##
