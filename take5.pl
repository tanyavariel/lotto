#!/usr/bin/perl
#
# For Take Five only - refer to take5.xls
use Getopt::Long;
use GD;

$result = GetOptions (
 #"numfile:s" => \$hf, # string
 "numfile=s" => \$numfile, # number file name - use take5-MASTER-DB.txt by default
 "numdel=s" => \$numdel, # number delimiter
 "games=i" => \$games,
 "subcolor=s" => \$subcolor,
 "delay=i" => \$delay,
 "autolimits" => \$autolimits,
 "infiloop" => \$infiloop, # infinite loop for debugging
 "winningnum=s" => \$winningnum,
 "balls=s" => \$balls,
 "verbose" => \$verbose,
 "help|?|usage" => \$usage
);

$NumbersToPick=5;
if ( !$balls ) {
$balls=39;
}

if ($numdel) { 
	if ($debug) { print "Got number delimiter=[$numdel]\n"; }
} else {
	$numdel='\s';
	if ($debug) { print "Default number delimiter=[$numdel] all white space\n"; }
}

if (!$numfile) { $numfile = "take5-MASTER-DB.txt"; }

printf("Got: numfile=[%s], numdel=[%s], games=[%d], autolimits=[%s], winningnum=[%s], verbose=[%s], usage=[%s]\n",$numfile,$numdel, $games, $autolimits, $winningnum, $verbose, $usage, $subcolor);

if ($NumbersToPick == "-?") { usage(); exit; }
if ($NumbersToPick < 1 or $NumbersToPick > 11 or $games <  1 or $balls < 1 or $balls > 100) { usage(); exit; }

sub usage () {
	print "USAGE: $0 -games=[Number of Games]\n";
	print "		 -numdel=[number delimiter for text file - default = all white space]\n";
	print "		 -numfile=Winning number file - take5-MASTER-DB.txt by default\n";
	print "		 -winningnum=['##:##:##:##:##']\n";
	print "		 -subcolor=red,blue,black,green";
	print "		 -balls=##  - Number of balls in game - default is 39 for take5 - powerball is 69";
	print "		 -autolimits - Auto gen the limits used instead of those calc via the spreadsheet\n";
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

print "How many numbers: $NumbersToPick # of games: $games  # of balls: $balls\n";

$balls++;  # Balls need to be one higher for calcs to work... don't know why... just an oversight

srand(time|$$);
	@onerangemin=( 1,1, 2, 9, 15, 28 );
	#@onerangemin=( 1,1, 6, 11, 21, 30 );
	@onerangemax=( 1, 13, 23, 29, 35, 39 );

if (!$autolimits) {
	# For five number games
	@onerangemin=( 1,1, 2, 9, 15, 28 );
	#@onerangemin=( 1,1, 6, 11, 21, 30 );
	@onerangemax=( 1, 13, 23, 29, 35, 39 );
	#@onerangemax=( 1,8, 20, 27, 36, 39 );
	@tworangemin=( 1, 3, 6, 11, 23  );
	@tworangemax=( 1, 48, 64, 73, 77 );
	$ftrangemin=17;
	$ftrangemax=64;
	$ltrangemin=53;
	$ltrangemax=101;
	$sumrangemin=66;
	$sumrangemax=142; # Jan 2011 to July 2012
}
else {
	$sumrangemin=$balls;
	if ($debug) { printf ("For each from 1 ... numbers[%d] \n",$NumbersToPick-1); }
	foreach $i ( 1 .. $NumbersToPick - 1 ) { # for 1 to 4
		$tworangemin[$i]=((($NumbersToPick+3)*$i)-($NumbersToPick))+1;
		$tworangemax[$i]=$tworangemin[$i]+$balls+$i;
	}
	foreach $i ( 1 .. $NumbersToPick ) {
		$sumrangemax=$sumrangemax+($balls-$i);  # good but no real use other than convenience
	}
	$sumrangemax=$sumrangemax-($balls+$NumbersToPick);
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
  #if ($debug) { print "Got winning file line number [$wl]\n"; }
  open(WINS, "$numfile");
  #open(WINS, "numbers_take5-4.txt");
  foreach ( 1 .. $wl ) {
    $y=<WINS>;
    chomp($y);
#	print "[[[$y]]]";
    }
   close(WINS);
   @winner=split(/$numdel/,$y);
   #$wdate=shift(@winner);
   #print "[$wdate][[@winner]]\n";
}

sub bynumber { $a <=> $b; }


sub getgame {
   $err=1;

   while ($err > 0 ) {
	   $cc++;

# Gen the 'unused' array of the numbers for use in - when a rand number is picked it is removed from this list so that it is not picked again
	foreach $i (1 .. $balls) {
		$s[$i]=$i;
		#print "s[i]= $s[$i]\n";
	}

# gen the rand number, if we get a zero keep trying, remove that number from our 'unused' array
	foreach $r (1 .. $NumbersToPick ) {
	        do {
		   $k=int(rand($balls+1)-$r);
		   #if ($k == 0) { print "ERROR: got zero for rand number [$k]\n"; }
		} while ($k < 1);
		# Set the number to the k'th number in our unused array
		$n2[$r]=$s[$k];
		if ($debug)  { print "$n2[$r]=$s[$k] - "; }
		# Remove the number from our array of unused
		foreach $t ($k .. $balls-$r) {
			$s[$t]=$s[$t+1];
		}
	}
	
	if ($debug)  { print "Take5 #: "; }
	@ns = sort bynumber @n2;
	if ($debug)  { print "SORTED:[@ns] "; }
	foreach $nf (1 .. $NumbersToPick) {
		#$n[$cc][$nf] = $ns[$nf];
		if ($debug)  { print "$ns[$nf] "; }
		$sum=$sum+$ns[$nf];
	}
	if ($debug) { print "\n"; }

	# First three Digit Sum
	$ft=0;
	foreach $w (1 .. 3) {
		if ($debug)  { print "Adding $ns[$w] to first three digit total of [$ft]\n"; }
		$ft=$ft+$ns[$w];
	}
	if ($debug) { print "First three total = [$ft]\n";}
	# Last three digit sum
	$lt=0;
	for ( $w=$NumbersToPick ;$w > $NumbersToPick-3; $w-- ) {
		if ($debug)  { print "Adding $ns[$w] to last three digit total of [$lt]\n"; }
		$lt=$lt+$ns[$w];
	}
	if ($debug) { print "Last three total = [$lt]\n";}

	# First Four Digit Sum
	$ff=0;
	foreach $w (1 .. 4) {
		$ff=$ff+$ns[$w];
	}
	# Last four digit sum
	$lf=0;
	for ( $w=$NumbersToPick ;$w > $NumbersToPick-4; $w-- ) {
		$lf=$lf+$ns[$w];
	}
	# By Twos
#	$cnt=0;
#	for ($w=1; $w <= $NumbersToPick-1 ; $w++ )  {
#		$bytwos[$w]=$ns[$w]+$ns[$w+1];
#		if ($debug) { print "GOT BYTWOS:W[$w] [$bytwos[$w]]\n"; }
#	}
#
#	if ($debug) { 
#		print "SUM=[$sum]  -  1st4[$ff] 2nd4[$lf]\n";
#			print "BYTWOS: ";
#		for ($w = 1; $w <= $NumbersToPick-1 ; $w++) {
#			print "$bytwos[$w],";
#		}
#			print "\n";
#	}
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
#	for ($w = 1; $w <= $NumbersToPick - 1; $w++) {
#		if ($debug) {print "CHECK BYTWOS: $bytwos[$w] \n"; }
#			if ($debug)  { print "Bytwos: $bytwos[$w] Checked against $tworangemin[$w] and $tworangemax[$w])\n"; }
#		if ($bytwos[$w] < $tworangemin[$w] or $bytwos[$w] > $tworangemax[$w] ) {
#			if ($debug)  { print "ERR - Bytwos: $bytwos[$w] out of range ($tworangemin[$w] and $tworangemax[$w])\n"; }
#			$err=1;
#		}
#	}
### Check by threes - best for take5?
		if ($debug) {print "CHECK THREES: first three[$ft] last three [$lt]\n"; }
		if ($debug)  { print "First three: $ft Checked against $ftrangemin and $ftrangemax)\n"; }
		if ($ft < $ftrangemin or $ft > $ftrangemax ) {
			if ($debug)  { print "ERR - First three: $ft out of range ($ftrangemin and $ftrangemax)\n"; }
			$err=1;
		}
		if ($debug)  { print "Last three: $lt Checked against $ltrangemin and $ltrangemax)\n"; }
		if ($lt < $ftrangemin or $lt > $ltrangemax ) {
			if ($debug)  { print "ERR - Last three: $lt out of range ($ltrangemin and $ltrangemax)\n"; }
			$err=1;
		}

#	for ($w = 1; $w <= $NumbersToPick; $w++) {
#		if ($debug)  { print "Byones: [$ns[$w]] Checked against $onerangemin[$w] and $onerangemax[$w])\n"; }
#		if ($ns[$w] < $onerangemin[$w] or $ns[$w] > $onerangemax[$w] ) {
#			if ($debug)  { print "ERR - Byones: $ns[$w] out of range ($onerangemin[$w] and $onerangemax[$w])\n"; }
#			$err=1;
#		}
#	}
		
	if ($err == 0) { $gg++; }

	if ($debug) { print "ERR[$err] iteration:[$cc] GoodGames=[$gg]\n";
		print "=================================\n";
	}
	$sum=0;
	if ($debug && $delay) { sleep ($delay); }
	if ($gg > $games) { return; }
   } # redo on error loop

} # done with Sub getgame


# Gen our game number hash
foreach $uu (1 .. $games) {
	getgame();
	if ($debug)  { print "Got number[$uu] of [$games]:[@ns]\n"; }
	foreach $w (1 .. $NumbersToPick) {
	  $yg[$uu][$w]=$ns[$w];
  }
  # pnums();
}

if ($debug) { print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"; }

# Print our numbers
foreach $uu (1 .. $games) {
	print "Got number[$uu] of [$games]:[";
	foreach $w (1 .. $NumbersToPick) {
	print "$yg[$uu][$w] ";
  }
  print "]\n";
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
	foreach $e ( 1 .. $NumbersToPick )  {
		foreach $q ( 1 .. $NumbersToPick ) {
			#if ($debug) { print "Checking winning number $winner[$q] against $yg[$uu][$e]\n"; }
			if ( $winner[$q] == $yg[$uu][$e] ) {
				$hits++;
				$hh[$hits]=$yg[$uu][$e];
			}
		}
	}
	if ($hits >1 ) { 
		$gameswon++;
		foreach $j ( 1 .. $NumbersToPick ) {
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

while ($ans ne "n") {
print "Print card to default printer? (y/n): ";
$ans=<>;
chomp($ans);
print "Your answer:[$ans]\n";
if ($ans eq "y") {
	printcard();
}
if ($ans eq "n") { exit;}
}


sub pnums {
	foreach $q ( 1 .. $NumbersToPick ) {
		printf ("%02d",$ns[$q]);
		if ($q < $NumbersToPick) { print ","; }
	}
	print "\n";
}



############################################
sub printcard {

#for $sgn (0 .. (int(($games-1)/5)*5)) {  # Five games per card so we'll create $im[$sgn]
#for $sgn (0 .. $games-1) {  # Five games per card so we'll create $im[$sgn]
#$sgn++;
#print "Got sgn[$sgn]\n";
# Create a new image
$im = new GD::Image(380,1100);

# Allocate some colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,0,0);
$blue = $im->colorAllocate(0,0,255);
$green = $im->colorAllocate(0,255,0);
if ( $subcolor) { $pcolor=$subcolor; }

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

@timeData = localtime(time);
($sec,$min,$hr,$day,$mth,$tyr,$dow,$doy,$dls) = @timeData;
$month=$mth+1;
$time="$hr:$min:$sec $month/$day/$tyr";
print "$time\n";
$im->string(gdSmallFont, 50, 40, $time, $pcolor);

# Print numbers in tiny font in red
#foreach $uu ((($sgn)*5)+1 .. ((($sgn-1)*5)+5)) {
foreach $uu (1 .. ((($sgn-1)*5)+5)) {
    foreach $q ( 1 .. $NumbersToPick ) {
	$nfc = sprintf ("%d",$yg[$uu][$q]);
	if ($q == 1) { 
	   $allnfc="$nfc";
	} else {
	   $allnfc="$allnfc,$nfc";
	}
    }
    print "[$allnfc]\n";
    $im->string(gdSmallFont, 230,200+$ls,$allnfc,$pcolor);
    $allnfc="";
    $ls=$uu*10;
}
# Put a black frame around the picture
#$im[$sgn]->rectangle(0,0,379,1099,$black);
# Print marker so we know which way to put card in
#line($x1,$y1,$x2,$y2,$color)
$im->line(50,50,60,60,$pcolor);
$im->line(70,50,60,60,$pcolor);

#foreach $uu (1 .. $games) {
#	print "Got number[$uu] of [$games]:[";
#	foreach $w (1 .. $NumbersToPick) {
#	print "$yg[$uu][$w] ";
#  }
#$games=4;

# Create a new array from 1 to $balls with ONLY the balls picked flagged and filled
foreach $uu ( 1 .. $games ) {  # next range of 5 games
    foreach $i (1 .. $NumbersToPick) { # how many numbers in the game
       foreach $b (1 .. $balls) {  # ttl num of balls
	   if ($yg[$uu][$i] == $b) {
		$allnums[$uu][$b]=$yg[$uu][$i];
	  print "Allnums[$uu][$b]=$allnums[$uu][$b]";
	   } else {
		$allnums[$uu][$b]=0;
	   }
	  }
	}
}

$rectwidth=16;
$recthi=7;
$blockwidthspacing=32;
$blockhispacing=19;
$gamespace=$recthi+15;

# Define the first rectangle
$sulx1=56; # X for Starting upper left for first block
$suly1=461; # Y for upper left
$sbrx2=$sulx1+$rectwidth;  # Bottom right
$sury2=$suly1+$recthi;  # Bottom right

# First fill for take5 card...
# Game # 1 Row 1 - numbers 36,31,26,21,16,11,6,1
foreach $ng ( 1 .. $games ) {
  print "\nPrinting game:[$ng]\n";
  for ($row=0;$row<=4;$row++) {  # 5 rows
  $pc=0;
   for ($col=7;$col>-1;$col--) {  # 8 cols
     $bc=(($col*5));
     $br=($row);
     $nm=($bc+1)+$br;
     foreach $picked ( 1 .. $NumbersToPick ) {
       if ($nm == $yg[$ng][$picked]) {
	print "*** $yg[$ng][$picked] [$pc][$row] ***\n";
     	$im->filledRectangle($sulx1+($blockwidthspacing*$pc),$suly1+($blockhispacing*$row),$sbrx2+($blockwidthspacing*$pc),$sury2+($blockhispacing*$row),$black);
#	$im->filledRectangle($sul+($blockwidthspacing*$col),$sll+($blockhispacing*$row),$sbr+($blockwidthspacing*$col),$sur+($blockhispacing*$row),$black);
       }
     }
   $pc++;
   }
  }
  $suly1=$suly1+($blockhispacing*$row)+$gamespace;
  $sury2=$sury2+($blockhispacing*$row)+$gamespace;

# Draw a blue oval
#$im[$sgn]->arc(50,50,55,75,0,360,$blue);
#$im[$sgn]->arc(50,50,95,75,0,360,$green);

# And fill it with red
#$im[$sgn]->fill(50,50,$red);
   print "[$suly1]";
}
# Open a file for writing 
open(PICTURE, ">gd-take5.jpeg") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->jpeg(100);
#print PICTURE $im->png;
close PICTURE;
print "\nPlease put cards in printer and hit enter to continue";
$ready=<>;
system("/usr/bin/lpr -o position=top-left gd-take5.jpeg");
#$png_data = $im->png;
# open (DISPLAY,"| display -") || die;
#        binmode DISPLAY;
#        print DISPLAY $png_data;
#        close DISPLAY;
}



sub newprintcard {

#for $sgn (0 .. (int(($games-1)/5)*5)) {  # Five games per card so we'll create $im[$sgn]
for $sgn (0 .. $games-1) {  # Five games per card so we'll create $im[$sgn]
#$sgn++;
print "Got sgn[$sgn]\n";
# Create a new image
$im[$sgn] = new GD::Image(380,1100);

# Allocate some colors
$white = $im[$sgn]->colorAllocate(255,255,255);
$black = $im[$sgn]->colorAllocate(0,0,0);
$red = $im[$sgn]->colorAllocate(255,0,0);
$blue = $im[$sgn]->colorAllocate(0,0,255);
$green = $im[$sgn]->colorAllocate(0,255,0);

# Make the background transparent and interlaced
$im[$sgn]->transparent($white);
$im[$sgn]->interlaced('true');

@timeData = localtime(time);
($sec,$min,$hr,$day,$mth,$tyr,$dow,$doy,$dls) = @timeData;
$month=$mth+1;
$time="$hr:$min:$sec $month/$day/$tyr";
print "$time\n";
$im[$sgn]->string(gdSmallFont, 50, 40, $time, $red);

# Print numbers in tiny font in red
#foreach $uu ((($sgn)*5)+1 .. ((($sgn-1)*5)+5)) {
foreach $uu (1 .. ((($sgn-1)*5)+5)) {
    foreach $q ( 1 .. $NumbersToPick ) {
	$nfc = sprintf ("%d",$yg[$uu][$q]);
	if ($q == 1) { 
	   $allnfc="$nfc";
	} else {
	   $allnfc="$allnfc,$nfc";
	}
    }
    print "[$allnfc]\n";
    $im[$sgn]->string(gdSmallFont, 230,200+$ls,$allnfc,$red);
    $allnfc="";
    $ls=$uu*10;
}
# Put a black frame around the picture
#$im[$sgn]->rectangle(0,0,379,1099,$black);
# Print marker so we know which way to put card in
#line($x1,$y1,$x2,$y2,$color)
$im[$sgn]->line(50,50,60,60,$red);
$im[$sgn]->line(70,50,60,60,$red);

#foreach $uu (1 .. $games) {
#	print "Got number[$uu] of [$games]:[";
#	foreach $w (1 .. $NumbersToPick) {
#	print "$yg[$uu][$w] ";
#  }
#$games=4;

# Create a new array from 1 to $balls with ONLY the balls picked flagged and filled
foreach $uu ( (($sgn)*5)+1 .. ((($sgn-1)*5)+5) ) {  # next range of 5 games
    foreach $i (1 .. $NumbersToPick) { # how many numbers in the game
       foreach $b (1 .. $balls) {  # ttl num of balls
	   if ($yg[$uu][$i] == $b) {
		$allnums[$uu][$b]=$yg[$uu][$i];
	  print "Allnums[$uu][$b]=$allnums[$uu][$b]";
	   } else {
		$allnums[$uu][$b]=0;
	   }
	  }
	}
}

$rectwidth=16;
$recthi=7;
$blockwidthspacing=32;
$blockhispacing=19;
$gamespace=$recthi+15;

# Define the first rectangle
$sulx1=56; # X for Starting upper left for first block
$suly1=461; # Y for upper left
$sbrx2=$sulx1+$rectwidth;  # Bottom right
$sury2=$suly1+$recthi;  # Bottom right

# First fill for take5 card...
# Game # 1 Row 1 - numbers 36,31,26,21,16,11,6,1
foreach $ng ( (($sgn)*5)+1 .. ((($sgn-1)*5)+5) ) {
  print "\nPrinting [$sgn] game:[$ng]\n";
  for ($row=0;$row<=4;$row++) {  # 5 rows
  $pc=0;
   for ($col=7;$col>-1;$col--) {  # 8 cols
     $bc=(($col*5));
     $br=($row);
     $nm=($bc+1)+$br;
     foreach $picked ( 1 .. $NumbersToPick ) {
       if ($nm == $yg[$ng][$picked]) {
	print "*** $yg[$ng][$picked] [$pc][$row] ***\n";
     	$im[$sgn]->filledRectangle($sulx1+($blockwidthspacing*$pc),$suly1+($blockhispacing*$row),$sbrx2+($blockwidthspacing*$pc),$sury2+($blockhispacing*$row),$black);
       }
     }
     $pc++;
   }
  }
  $suly1=$suly1+($blockhispacing*$row)+$gamespace;
  $sury2=$sury2+($blockhispacing*$row)+$gamespace;

# Draw a blue oval
#$im[$sgn]->arc(50,50,55,75,0,360,$blue);
#$im[$sgn]->arc(50,50,95,75,0,360,$green);

# And fill it with red
#$im[$sgn]->fill(50,50,$red);
   print "[$suly1]";
   $pg++;
   if ($pg>5) { 
	$pg=0;
        createNprintImage();
   }	
 }
}
}
