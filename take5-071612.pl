#!/usr/bin/perl
#
# For Take Five only - refer to take5.xls
use Getopt::Long;

$result = GetOptions (
 #"numfile:s" => \$hf, # string
 "numfile=s" => \$numfile, # number file name - use take5-MASTER-DB.txt by default
 "numdel=s" => \$numdel, # number delimiter
 "games=i" => \$games,
 "delay=i" => \$delay,
 "byhand" => \$byhand, # Delete password file when completed
 "infiloop" => \$infiloop, # infinite loop for debugging
 "winningnum=s" => \$winningnum,
 "verbose" => \$verbose,
 "help|?|usage" => \$usage
);

#$numbers = $ARGV[0];
$numbers=5;
#$games = $ARGV[1];
#$balls=$ARGV[2];
$balls=39;
#$byhand=$ARGV[3];
#$winningnum=$ARGV[4];

if ($numdel) { 
	if ($debug) { print "Got number delimiter=[$numdel]\n"; }
} else {
	$numdel="\t";
	if ($debug) { print "Default number delimiter=[$numdel]tab\n"; }
}

if (!$numfile) { $numfile = "take5-MASTER-DB.txt"; }

printf("Got: numfile=[%s], numdel=[%s], games=[%d], byhand=[%s], winningnum=[%s], verbose=[%s], usage=[%s]\n",$numfile,$numdel, $games, $byhand, $winningnum, $verbose, $usage);

if ($numbers == "-?") { usage(); exit; }
if ($numbers < 1 or $numbers > 11 or $games <  1 or $balls < 1 or $balls > 100) { usage(); exit; }

sub usage () {
	print "USAGE: $0 -games=[Number of Games]\n";
	print "		 -numdel=[number delimiter for text file - default = TAB]\n";
	print "		 -numfile=Winning number file\n";
	print "		 -winningnum=['##:##:##:##:##']\n";
	print "		 -byhand\n";
	print "		 -verbose\n";
	print "		 [-?|-help|-usage] This usage message\n";
	exit;
}

$debug=$verbose;
$debug2=$verbose;


if ( $winningnum ) {
	@wnn = split(/:/,$winningnum);
	print "Using WINNING NUMBER: [@wnn]\n";
}

#open(WINS, "numbers_take5-4.txt");
open(WINS, "$numfile");
while (<WINS>) {
	$lines++; 
}
close(WINS);

print "How many numbers: $numbers # of games: $games  # of balls: $balls\n";
srand(time|$$);
	@onerangemin=( 1,1, 2, 9, 15, 28 );
	#@onerangemin=( 1,1, 6, 11, 21, 30 );
	@onerangemax=( 1, 13, 23, 29, 35, 39 );

if ($byhand) {
	# For five number games
	@onerangemin=( 1,1, 2, 9, 15, 28 );
	#@onerangemin=( 1,1, 6, 11, 21, 30 );
	@onerangemax=( 1, 13, 23, 29, 35, 39 );
	#@onerangemax=( 1,8, 20, 27, 36, 39 );
	@tworangemin=( 1, 3, 6, 11, 23  );
	@tworangemax=( 1, 48, 64, 73, 77 );
	$sumrangemin=33;
	$sumrangemax=158;
}
else {
	$sumrangemin=$balls;
	if ($debug) { printf ("For each from 1 ... numbers[%d] \n",$numbers-1); }
	foreach $i ( 1 .. $numbers - 1 ) { # for 1 to 4
		$tworangemin[$i]=((($numbers+3)*$i)-($numbers))+1;
		$tworangemax[$i]=$tworangemin[$i]+$balls+$i;
	}
	foreach $i ( 1 .. $numbers ) {
		$sumrangemax=$sumrangemax+($balls-$i);  # good but no real use other than convenience
	}
	$sumrangemax=$sumrangemax-($balls+$numbers);
}

if ($infiloop) {
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
  open(WINS, "$numfile");
  #open(WINS, "numbers_take5-4.txt");
  foreach ( 1 .. $wl ) {
    $y=<WINS>;
    chop($y);
    }
   close(WINS);
   @winner=split(/$numdel/,$y);
   shift(@winner);
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
	
	if ($debug)  { print "Take5 #: "; }
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
	for ($w=1; $w <= $numbers-1 ; $w++ )  {
		$bytwos[$w]=$ns[$w]+$ns[$w+1];
		if ($debug) { print "GOT BYTWOS:W[$w] [$bytwos[$w]]\n"; }
	}

	if ($debug) { 
		print "SUM=[$sum]  -  1st4[$ff] 2nd4[$lf]\n";
			print "BYTWOS: ";
		for ($w = 1; $w <= $numbers-1 ; $w++) {
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
		if ($debug)  { print "ERR - SUM Out of range ($sumrangemin to $sumrangemax): $sum\n"; }
		$err=1;
	}
	for ($w = 1; $w <= $numbers - 1; $w++) {
		if ($debug) {print "CHECK BYTWOS: $bytwos[$w] \n"; }
			if ($debug)  { print "Bytwos: $bytwos[$w] Checked against $tworangemin[$w] and $tworangemax[$w])\n"; }
		if ($bytwos[$w] < $tworangemin[$w] or $bytwos[$w] > $tworangemax[$w] ) {
			if ($debug)  { print "ERR - Bytwos: $bytwos[$w] out of range ($tworangemin[$w] and $tworangemax[$w])\n"; }
			$err=1;
		}

	}
	for ($w = 1; $w <= $numbers; $w++) {
		if ($debug)  { print "Byones: [$ns[$w]] Checked against $onerangemin[$w] and $onerangemax[$w])\n"; }
		if ($ns[$w] < $onerangemin[$w] or $ns[$w] > $onerangemax[$w] ) {
			if ($debug)  { print "ERR - Byones: $ns[$w] out of range ($onerangemin[$w] and $onerangemax[$w])\n"; }
			$err=1;
		}
	}
		
	if ($err == 0) { $gg++; }

	if ($debug) { print "ERR[$err] iteration:[$cc] GoodGames=[$gg]\n";
		print "=================================\n";
	}
	$sum=0;
	if ($debug && $delay) { sleep ($delay); }
	if ($gg > $games) { return; }
   } # redo on error loop

} # done with Sub getgame

foreach $uu (1 .. $games) {
	getgame();
	if ($debug)  { print "Got number[$uu] of [$games]:[@ns]\n"; }
	foreach $w (1 .. $numbers) {
	  $yg[$uu][$w]=$ns[$w];
  }
  # pnums();
}

if ($debug) { print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"; }

# Print our numbers
foreach $uu (1 .. $games) {
	if ($debug)  { print "Got number[$uu] of [$games]:["; }
	foreach $w (1 .. $numbers) {
	if ($debug)  { print "$yg[$uu][$w] "; }
  }
  if ($debug) { print "]\n"; }
}

#print "And the WINNER IS.... ";
if ( $winningnum ) { 
	@winner = @wnn ; 
} else {
	#getgame();
	#@winner=@ns;
	print "Getting winner.... ["; sleep(1);
	getwinner();
}
#pnums();
# Take FIVE Only getwinner();
print "@winner]\n";


#print "SUCKER!!!!\n";
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

