#!/usr/bin/perl
#
# For lotto + bonus only - refer to lotto-mega-bonus.xls

$numbers = $ARGV[0];
$games = $ARGV[1];
$balls=$ARGV[2];
$byhand=$ARGV[3];
$winningnum=$ARGV[4];

$DoByOnes=0;
$DoByTwos=0;

if ($numbers == "-?") { usage(); exit; }
if ($numbers < 1 or $numbers > 11 or $games <  1 or $balls < 1 or $balls > 100) { usage(); exit; }

sub usage () {
	print "USAGE:lotto.pl [Number of Numbers (6 + 1 bonus = 7) ] [Number of Games] [Number of Balls] [Byhand anystring]\n";
}

$debug=3;
#$debug2=4;
$err=1;

if ( $winningnum ) {
	@wnn = split(/-/,$winningnum);
	print "Using WINNING NUMBER: [@wnn]\n";
}

open(WINS, "numbers_take5-4.txt");
while (<WINS>) {
	$lines++; 
}
close(WINS);

print "How many numbers: $numbers # of games: $games  # of balls: $balls ByHand:[$byhand]\n";
srand(time|$$);

if ($byhand) {
	# For five number games
	@onerangemin=( 1,1, 6, 14, 22, 30 );
	#@onerangemin=( 1,1, 6, 11, 21, 30 );
	@onerangemax=( 1,8, 20, 28, 34, 39 );
	#@onerangemax=( 1,8, 20, 27, 36, 39 );
	@tworangemin=( 1, 3, 11, 25, 44  );
	@tworangemax=( 1, 44, 55, 67, 75 );
	$sumrangemin=55;
	$sumrangemax=155;
}
else {
	$sumrangemin=$balls;
	foreach $i ( 1 .. $numbers - 1 ) {
		$tworangemin[$i]=((($numbers+3)*$i)-($numbers))+1;
		$tworangemax[$i]=$tworangemin[$i]+$balls+$i;
	}
	foreach $i ( 1 .. $numbers ) {
		$sumrangemax=$sumrangemax+($balls-$i);
	}
	$sumrangemax=$sumrangemax-($balls+$numbers);
}

if ($debug2) {
	while (1) {
		print "Check number range\n";
		getgame();
		pnums();
		sleep (1);
	}
	exit;
}

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

   while ($err > 0 ) {
	$cc++;

	foreach $i (1 .. $balls) {
		$s[$i]=$i;
		#print "s[i]= $s[$i]\n";
	}

	foreach $r (1 .. $numbers ) {
		$k=int(rand($balls+1)-$r);
		$n2[$r]=$s[$k];
		if ($debug)  { print "$n2[$r]=$s[$k] - "; }
		foreach $t ($k .. $balls-$r) {
			$s[$t]=$s[$t+1];
		}
	}
	
	if ($debug)  { print "\nNew LOTTO #: \n"; }
	@ns = sort bynumber @n2;
	if ($debug)  { print "SORTED:[@ns] \n"; }
	foreach $nf (1 .. $numbers) {
		#$n[$cc][$nf] = $ns[$nf];
		if ($debug)  { print "$ns[$nf] "; }
		$sum=$sum+$ns[$nf];
	}
	if ($debug) { print "\nSum: [$sum]\n"; }


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
	print "First Four/Last Four: 1st4[$ff] 2nd4[$lf]\n";

	# By Twos
	if ($DoByTwos > 0) {
	  $cnt=0;
	  for ($w=1; $w <= $numbers-1 ; $w++ )  {
		$bytwos[$w]=$ns[$w]+$ns[$w+1];
		if ($debug) { print "GOT BYTWOS:W[$w] [$bytwos[$w]]\n"; }
	  }

	  if ($debug) { 
			print "BYTWOS: ";
		for ($w = 1; $w < $numbers-1 ; $w++) {
			print "$bytwos[$w],";
		}
			print "\n";
	  }
  	} else { print "DoByTwos is OFF!\n"; }

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

	if ($DoByTwos) {
	   for ($w = 1; $w <= $numbers - 1; $w++) {
		if ($debug) {print "CHECK BYTWOS: $bytwos[$w] \n"; }
			if ($debug)  { print "Bytwos: $bytwos[$w] Checked against $tworangemin[$w] and $tworangemax[$w])\n"; }
		if ($bytwos[$w] < $tworangemin[$w] or $bytwos[$w] > $tworangemax[$w] ) {
			if ($debug)  { print "Bytwos: $bytwos[$w] out of range ($tworangemin[$w] and $tworangemax[$w])\n"; }
			$err=1;
		}

	   }
	}

	if ($DoByOnes) {
	   for ($w = 1; $w <= $numbers; $w++) {
		if ($debug)  { print "Byones: [$ns[$w]] Checked against $onerangemin[$w] and $onerangemax[$w])\n"; }
		if ($ns[$w] < $onerangemin[$w] or $ns[$w] > $onerangemax[$w] ) {
			if ($debug)  { print "Byones: $ns[$w] out of range ($onerangemin[$w] and $onerangemax[$w])\n"; }
			$err=1;
		}
	   }
	}
		

	#$err=1;
	if ($debug && $err == 0) { 
		print "ERR[$err] iteration:[$cc < $games]\n";
		print "=================================\n";
	}

	$sum=0;
	if ($debug) { sleep (2); }
   } # redo on error loop

} # done with Sub getgame

foreach $uu (1 .. $games) {
	print "Get Game #: [$uu]\n";
	getgame();
	print "Got Game #: [$uu]\n";
	foreach $w (1 .. $numbers) {
	  $yg[$uu][$w]=$ns[$w];
  }
  # pnums();
}
print "And the WINNER IS.... [";
if ( $winningnum ) { 
	@winner = @wnn ; 
} else {
	#getgame();
	#@winner=@ns;
	print "Getting winner....\n"; sleep(1);
	getwinner();
}
#pnums();
# Take FIVE Only getwinner();
print "@winner] - ";


print "SUCKER!!!!\n";
$winnings=0;
$free=0;
$gameswon=0;
foreach $uu (1 .. $games) {
	$hits=0;
	if ($hits >2 ) { print "GAME #[$uu]: "; }
	foreach $e ( 1 .. $numbers )  {
		foreach $q ( 1 .. $numbers ) {
			if ( $winner[$q] == $yg[$uu][$e] ) {
				$hits++;
				$hh[$hits]=$yg[$uu][$e];
			}
		}
	}
	if ($hits >1 ) { 
		$gameswon++;
		foreach $j ( 1 .. $numbers ) {
			print "[$yg[$uu][$j]]";
		}
		print " - ";
		foreach $e ( 1 .. $hits) {
			print "($hh[$e])";
			$hh[$e]=0;
		}
		if ($hits == 2 ) { print " - Free Game "; $free++; }
		if ($hits == 3 ) { print " - \$ 25 bucks "; $winnings=$winnings+25; }
		if ($hits == 4 ) { print " - \$ 450 bucks "; $winnings=$winnings+450; }
		if ($hits == 5 ) { print " - JackPot!!!!!!!!!!!!!!!!!!!!!! "; exit; }
		print "\n";

	}
}
$per=(($gameswon / $games)*100);
print "GamesWon=[$gameswon] - GamesPlayed=[$games] - PercentWon=[ $per ]\n";
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
