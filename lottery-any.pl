#!/usr/bin/perl
#
# For Take Five only - refer to take5.xls

$numbers = $ARGV[0];
$games = $ARGV[1];
$balls=$ARGV[2];

$debug=2;
open(WINS, "numbers_take5-4.txt");
while (<WINS>) {
	$lines++; 
}
close(WINS);

print "How many numbers: $numbers # of games: $games  # of balls: $balls\n";
srand(time|$$);

# For five number games
#@tworangemin=( 3, 11, 25, 44 );
foreach $i ( 1 .. $numbers ) {
	$tworangemin[$i]=3+((10-$i)*$i);
	$tworangemax[$i]=$tworangemin[$i]+$balls;
}
#@tworangemax=( 44, 55, 67, 75 );
#$sumrangemin=55;
$sumrangemin=$balls;
#$sumrangemax=155;
foreach $i ( 1 .. $numbers ) {
	$sumrangemax=$sumrangemax+($balls-$i);
}
$sumrangemax=$sumrangemax-$balls;

sub getwinner {
  $wl=int(rand($lines+1)); 
  open(WINS, "numbers_take5-4.txt");
  foreach ( 1 .. $wl ) {
    $y=<WINS>;
    chop($y);
    }
   close(WINS);
   @winner=split(/,/,$y);
}

sub bynumber { $a <=> $b; }


sub getgame {
   $err=1;

   while ($err != 0 ) {

	foreach $i (1 .. $balls) {
		$s[$i]=$i;
		#print "s[i]= $s[$i]\n";
	}

	foreach $r (1 .. $numbers ) {
		$k=int(rand(($balls+1)-$r));
		$n2[$r]=$s[$k];
		if ($debug)  { print "$n2[$r]=$s[$k] - "; }
		foreach $t ($k .. $balls-$r) {
			$s[$t]=$s[$t+1];
		}
	}
	
	if ($debug)  { print "LOTTO #: "; }
	@ns = sort bynumber @n2;
	if ($debug)  { print "SORTED:[@ns] "; }
	foreach $nf (1 .. $numbers) {
		#$n[$cc][$nf] = $ns[$nf];
		if ($debug)  { print "$ns[$nf] "; }
		$sum=$sum+$ns[$nf];
	}
	if ($debug) { print "\n"; }


	# First Four Digit Sum
	$ff=0;
	foreach $w (1 .. 4) {
		$ff=$ff+$ns[$w];
	}
	# Last four digit sum
	$lf=0;
	for ( $w=$numbers ;$w > $numbers-4; $w-- ) {
		$lf=$lf+$ns[$w];
	}
	# By Twos
	$cnt=0;
	for ($w=1; $w < $numbers ; $w++ )  {
		$bytwos[$w]=$ns[$w]+$ns[$w+1];
	}

	if ($debug) { 
		print "SUM=[$sum]  -  1st4[$ff] 2nd4[$lf]\n";
			print "BYTWOS: ";
		for ($w = 1; $w < $numbers ; $w++) {
			print "$bytwos[$w],";
		}
			print "\n";
	}
		#123456
		#12
		# 23
		#  34
		#   45
		#    56
	

	$err=0;
	if ($debug) { print "SUMRANGEMIN:[$sumrangemin] to SUMRANGEMAX:[$sumrangemax]\n"; }
	if ( $sum < $sumrangemin or $sum > $sumrangemax ) {
		if ($debug)  { print "SUM Out of range ($sumrangemin to $sumrangemax): $sum\n"; }
		$err=1;
	}
	for ($w = 1; $w < $numbers-1 ; $w++) {
		if ($debug) {print "CHECK BYTWOS: $bytwos[$w] \n"; }
			if ($debug)  { print "Bytwos: $bytwos[$w] Checked against $tworangemin[$w] and $tworangemax[$w])\n"; }
		if ($bytwos[$w] < $tworangemin[$w] or $bytwos[$w] > $tworangemax[$w] ) {
			if ($debug)  { print "Bytwos: $bytwos[$w] out of range ($tworangemin[$w] and $tworangemax[$w])\n"; }
			$err=1;
		}

	}

	if ($debug) { print "ERR[$err] iteration:[$cc < $games]\n";
		print "=================================\n";
	}

	$sum=0;
	if ($debug) { sleep (2); }
   } # redo on error loop

} # done with Sub getgame

foreach $uu (1 .. $games) {
	getgame();
	foreach $w (1 .. $numbers) {
	  $yg[$uu][$w]=$ns[$w];
  }
  # pnums();
}
print "And the WINNER IS.... [";
getgame();
@winner=@ns;
#pnums();
# Take FIVE Only getwinner();
print "@winner] - ";


print "SUCKER!!!!\n";
$winnings=0;
foreach $uu (1 .. $games) {
	$hits=0;
	if ($hits >2 ) { print "GAME #[$uu]: "; }
	foreach $e ( 1 .. $numbers )  {
		foreach $q ( 1 .. $numbers ) {
			if ( $winner[$q]==$yg[$uu][$e] ) {
				if ($hits >2 ) { print "($yg[$uu][$e])"; }
				$hits++;
			}
		}
	}
	#	if ($hits == 2 ) { print " - Free Game "; }
	if ($hits == 3 ) { print " - \$ 25 bucks "; $winnings=$winnings+25; }
	if ($hits == 4 ) { print " - \$ 450 bucks "; $winnings=$winnings+450; }
	if ($hits == 5 ) { print " - JackPot!!!!!!!!!!!!!!!!!!!!!! "; exit; }
	if ($hits >2 ) { print "\n"; }
}
print "WINNINGS: [$winnings]\n";


sub pnums {
	foreach $q ( 1 .. $numbers ) {
		printf ("%02d",$ns[$q]);
		if ($q < $numbers) { print ","; }
	}
	print "\n";
}

#if ($forever) {
#		@ww=split(/,/,$y);
#		#print "@ww\n";
#			$c3=0;
#		foreach $op (@ww) {
#			foreach $ty ( 1 .. 6) {
#				if ($n[1][$ty] == $op) {
#					$c3++;
#					$win[$c3]=$n[1][$ty]; 
#					#		print "--C3[$c3] - WIN $win[$c3] - N $n[1][$ty]";
#				}
#			}
#		}
#		if ($c3>$forever) { 
#			print "Iteration[$it]: ";
#			foreach $ry (1 .. $c3) { 
#				print "$win[$ry], "; 
#			}
#			print "\n";
#		}
#	}
#	close(WINS);
#
#}
#
#
#
