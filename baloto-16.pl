#!/usr/bin/perl
#This is a test pull
#
#And another test to mytest branch
#
# For Take Five only - refer to take5.xls
use Getopt::Long;
use GD;
#use Mail::Sender;
#use Mail;

$result = GetOptions (
 #"numfile:s" => \$hf, # string
 "mailgame" => \$mailgame, # Mail game output to users in comma sep list
 "csv" => \$csv, # Only print out the numbers from the $numfile in csv format for use in a spreadsheet
 "prcard" => \$prcard, # If this option is specified than prompt to print card come up.
 "numfile=s" => \$numfile, # number file name - use take5-MASTER-DB.txt by default
 "numdel=s" => \$numdel, # number delimiter
 "games=i" => \$games,
 "nogih=i" => \$nogih,  ## Number of games to use in calc from history file
 "subcolor=s" => \$subcolor,
 "delay=i" => \$delay,
 #"autolimits" => \$autolimits,
 "sf" => \$showfreqs,
 "e" => \$editnums,
 "infiloop" => \$infiloop, # infinite loop for debugging
 "winningnum=s" => \$winningnum,
 "balls=s" => \$balls,
 "extraball=i" => \$extraball,
 "verbose" => \$verbose,
 "help|?|usage" => \$usage
);

sub usage () {
	print "USAGE: $0\n";
	print " -games=[Number of Games]\n";
        print " -nogih=[number of games to use in calculations from $numfile - default = 104 games per year / 12 months * 2 months = 17.333 - So round up to 20... why not?? :-)]\n";
	print " -e - Edit number file with VI\n";
	print " -mailgame - Mail the results to comma sep list of users\n";
	print " -csv - Only print the numfile in csv format for use in spreadsheets or verification\n";
	print " -numdel=[number delimiter for text file - default = all white space]\n";
	print " -numfile=Winning number file - take5-MASTER-DB.txt by default\n";
	print " -winningnum=['##:##:##:##:##']\n";
	print " -subcolor=red,blue,black,green\n"; 
        print " -balls=##  - Number of balls in game - default is 39 for take5 - powerball is 69\n";
        print " -extraball=##  - Number of numbers for the extra ball eg; baloto is 1 to 16 so it would be 16 in that case\n";
	#print " -autolimits - Auto gen the limits used instead of those calc via the spreadsheet\n";
	print " -sf - Show number frequencys for use in hot number calcs\n";
	print " -verbose\n";
	print " [-?|-help|-usage] This usage message\n";
	exit;
}

sub csv {
  $po = shift;

   my $lines=0;
   open(WINS, "$numfile");
   if ($debug) { print ("[$numfile] opened... reading...\n"); }
   while (<WINS>) {
	$lines++; 
        #($dt,$wnum) = split(/[\t| ]/); - Take 5
	($dt,@wnum) = split(/,/);  # Baloto
        #chomp($wnum);
        if ($debug) { print (" ---> @wnum") };
        #@snums = split(/$numdel/,$wnum);
        $cnums = join(",", @wnum);
	if ($debug) { print ("dt=[$dt] cnums=[$cnums]\n"); }
	if ( ! $po ) { print ("$dt,$cnums\n");  }
   }
   close(WINS);
   return;
}

sub getsumdiffs {
	# How many sets of three to add together is always the number of numbers in the row minus 2 so (10 - 2) = 8 sets of three for a ten number game - easy peasy!
	my @snums = @_;
	my $numcnt = @snums;
	my $numofthrees=$numcnt-2;  # So for a 5 number game this will be a set of three numbers
	my @threesums;
	if ( $debug ) {print ("getsumdiffs: snums=[@snums] numcnt=[$numcnt]\n"); }
	for ($ftc=0; $ftc<$numofthrees; $ftc++) {
		if ($debug) { print ("[$numcnt] [$numofthrees] [$ftc] ->Adding: $snums[$ftc] + $snums[$ftc+1] + $snums[$ftc+2] ---> \n"); }
		$threesums[$ftc] = $snums[$ftc]+$snums[$ftc+1]+$snums[$ftc+2];
	}  # @tc now contains the rows three count sums (number of numbers - 2 = number of sets of three)

	# Now get three set diffs - this should always be an array size of $numofthrees
	my @threediffs; # Need this because our main array hols a ref to each new array of threedeiffs
	for ( $cc=0; $cc<$numofthrees-1; $cc++) {
		$threediffs[$cc] = $threesums[$cc+1]-$threesums[$cc];
	}
	$threediffs[$#threediffs+1] = $threesums[$cc] - $threesums[0];  # Here we get the last minus the first 

	# Finally... well almost finally... we get the sum for the whole row.  A bit of perl magic..
	$rsum = 0;  # Need to declare or perl magic won't work
	$rsum += $_ for @snums;
	###  Stick it into an array here so we can fit it into our column calcs easily
	my @rowsum;
	$rowsum[0]=$rsum;

	return (\@threesums, \@threediffs, \@rowsum);
}

sub createarrays {

	# For five number games
	# Row arrays consit of 'date' as the key
	# So we can have a single array to hold all data pertinent to that date
	# { 'date', 'ft', 'mt', 'lt', 'ts', 'mmf', 'lmm', 'lmf' }
	my @threesums=();
	@rowcalcs=();  # Contains the sums for the row
###
	# Originally it was sep arrays.
	# @ft=First three  @mt=Mid three  @lt=last three 
	# @mmf='mid three minus first three'  @llm='last three minus mid three'  @lmf='last three minus first three'
###

	## Populate the arrays here
   $lines=0;
   open(WINS, "$numfile");
   if ($debug) { print ("[$numfile] opened... reading...\n"); }
   while (<WINS>) {
	$lines++; 
        # ($dt,$wnum) = split(/[\t| ]/); Take5
	($dt,@snums) = split(/,/);  # Baloto
        #chomp($wnum);
        #$cnums = $wnum;
        #$cnums =~ s/$numdel/\,/g;
        #@snums = split(/$numdel/,$wnum);  # THis is our current row array of N numbers (5 for take 5 but this can be dynamic if I program this right

        $extranum = pop(@snums);  # get the extraball
	$numcnt=@snums;
	
	### Create hot number matrix
	@numfreq[$balls-1];
	for ( $non=0; $non<$numcnt; $non++ ) {  ## non is number of numbers less the extra
		$numfreq[$snums[$non]]++;  ## Counting the number of times this number hit
		if ( $debug) { print ("Counted num[$snums[$non]] = $numfreq[$snums[$non]]\n"); }
	}
		


	# How many sets of three to add together is always the number of numbers in the row minus 2 so (10 - 2) = 8 sets of three for a ten number game - easy peasy!
	my @threesums, my @threediffs, my @rowsum;
	my ( $tsums, $tdiffs, $rwsm ) = &getsumdiffs(@snums);
	@threesums=@{$tsums}; @threediffs=@{$tdiffs}; @rowsum=@{$rwsm};

	### Now we build the array of arrays for @rowcals with the date as the key
    	### Pan comida!! - Need to use [] around each array to make sure it is assed as a sep array
	$rowcalcs[$lines] = [ [@snums], [ @threesums] , [ @threediffs], [@rowsum] ];

	if ($debug) { print ("Line=[$lines], dt=[$dt] snums=[@snums] $threesums[0] rowsum= [ $rowcalcs[$lines][3][0]] ThreeSums="); 
			for ( $cc=0; $cc<$numofthrees; $cc++) { print ("[ $rowcalcs[$lines][1][$cc] ]"); }
			for ( $cc=0; $cc<$numofthrees; $cc++) { print ("[ $rowcalcs[$lines][2][$cc] ]"); }
			print ("\n");
	}

#	if ( ! $po ) { print ("$dt,$cnums\n");  }
   }
   close(WINS);
	### Now we get avgs and other col stats

	# { 'colsum', 'colavg', colmax, colmin, AvgDev, StdDev, 'avg+AvgDev+StdDev', 'avg-AvgDev-StdDev' - Using the combo of sums and diffs for both Ave (not avg) dev and std dev give the best ranges for the sums...  
	@colsum; # Total for this column - used to avgs below
	@colavg; # This is the average for each column
	@colmax; # The max found for this column
	@colmin; # the min found """"""


#	foreach ($rowcalcs[0]) {
#	$aacc++;
#	}
	$aacc=@{$rowcalcs[1]}; # This gives us the number of arrays in @rowcalcs
	$aac2=@{$rowcalcs[1][3]}; 
	if ( $debug ) { print ("Size of rowcalcs=[ $aacc ] second # of element of rowcalcs = $aac2 \n"); }

	for ($noa=0; $noa<$aacc; $noa++) {   ### This is our outermost array @rowcalcs.. ie all of the arrays in this array will now be iterated over
	    for ($noc=0; $noc<@{$rowcalcs[1][$noa]}; $noc++) {
		$cmax=0; $cmin=1000; $nmin=0; # Setting $cmin to a arbitrarily high number does not hurt
		for ($nol=1; $nol<=$lines; $nol++ ){ 
		    if ( $debug ) { print ("[$nol] -> $rowcalcs[$nol][$noa][$noc]\n"); }
	    	    $colsum[$noa][$noc] += $rowcalcs[$nol][$noa][$noc];
		    if ($rowcalcs[$nol][$noa][$noc]<$cmin) { $cmin=$rowcalcs[$nol][$noa][$noc]; }
		    if ($rowcalcs[$nol][$noa][$noc]>$cmax) { $cmax=$rowcalcs[$nol][$noa][$noc]; }
		}
		$cavg=$colsum[$noa][$noc]/$lines;
		$colavg[$noa][$noc]=$cavg;
		$colmax[$noa][$noc]=$cmax;
		$colmin[$noa][$noc]=$cmin;
		
		if ( $debug) { print ("colsum[$noa][$noc] -> $colsum[$noa][$noc] Avg=[$cavg] Max=[$cmax] Min=[$cmin] \n"); }
		### We can only get the average deviation (avedev) after we have the average for each column
	    }
	}

######B1: =AVEDEV( A1:A5 )
######B2: =SUM( ARRAYFORMULA( ABS( (A1:A5)-AVERAGE(A1:A5) ) ) ) / COUNT(A1:A5) */
########: My interpretation: for each number in the column ( deviation = abs( colnumber - colavg) / lines )
#### Stddev = subtract each num from the average(mean) -> square the abs value of the difference -> sum all of these and divide by $lines -> take the sqr rt of this result
	@colavedev; 
	### We can only get the average and std deviation (avedev y stddev) after we have the average for each column
	### So we need to reiterate over all of the arrays... no easier way I think. 
	for ($noa=0; $noa<$aacc; $noa++) {   ### This is our outermost array @rowcalcs.. ie all of the arrays in this array will now be iterated over
	    $tmpab=0;
	    for ($noc=0; $noc<@{$rowcalcs[1][$noa]}; $noc++) {
	        if ( $debug ) { print ("For dev calcs now -> [$nol] -> $rowcalcs[$nol][$noa][$noc]\n"); }
		### We need an inner here - avedev needs to subtract the number average from the number and use the abs value 
		### http://formulas.tutorvista.com/math/average-deviation-formula.html
		$tmpad=0; $tmpsd=0;
		for ($nol=1; $nol<=$lines; $nol++ ){ 
		    $tmpab=abs($rowcalcs[$nol][$noa][$noc]-$colavg[$noa][$noc]);
		    $tmpad+=$tmpab;
		    $tmpsd+=$tmpab ** 2;
		    if ($debug) { print ("[$nol] -> $rowcalcs[$nol][$noa][$noc] $colavg[$noa][$noc]-> absval = $tmpab avgdevtot=$tmpad stddevtot=$tmpsd\n"); }
		}
		$avedev=$tmpad/$lines;
		$colavedev[$noa][$noc] = $avedev;
		$stddev=sqrt($tmpsd/$lines);
		$colstddev[$noa][$noc] = $stddev;
		if ( $debug) { print ("AveDev = [$colavedev[$noa][$noc]]  StdDev=[$colstddev[$noa][$noc]\n"); }
		if ($debug) { print ("colsum[$noa][$noc] -> $colsum[$noa][$noc] Avg=[$cavg] Max=[$cmax] Min=[$cmin] \n"); }
		### We can only get the average deviation (avedev) after we have the average for each column
	    }
	}
	


}


###################################   Start of logic ##########################

$NumbersToPick=5;
if (!$balls) {
$balls=43;  ## For Baloto
#$balls=39;  ## For take5 

}

if ( !$extraball ) {
    $extraball = 16;
}

if ( !$nogih ) {
    $nogih = 20;  ## See calc in 'usage' for reason to use '20' here.
}

if ($numdel) { 
	if ($debug) { print "Got number delimiter=[$numdel]\n"; }
} else {
	## $numdel='\s'; This was for the old format after the manual massage
        #$numdel='\-';
	$numdel=',';
	if ($debug) { print "Default number delimiter=[$numdel]\n"; }
}

if (!$numfile) { $numfile = "baloto.txt"; }

if ($editnums) {
	print "Editing $numfile...\n";
	$editstat = system ("vi","$numfile");
	exit();
}


#printf("Got: numfile=[%s], numdel=[%s], games=[%d], autolimits=[%s], winningnum=[%s], verbose=[%s], usage=[%s]\n",$numfile,$numdel, $games, $autolimits, $winningnum, $verbose, $usage, $subcolor);
#printf("Got: numfile=[%s], numdel=[%s], games=[%d], winningnum=[%s], verbose=[%s], usage=[%s]\n",$numfile,$numdel, $games, $winningnum, $verbose, $usage, $subcolor);
printf("Got: numfile=[%s], numdel=[%s], games=[%d], number of games to use from history (nogih)=[%s], autolimits=[%s], winningnum=[%s], verbose=[%s], usage=[%s], subcolor=[%s], balls=[%d], extraballs=[%d]\n",$numfile,$numdel, $games, $nogih, $autolimits, $winningnum, $verbose, $usage, $subcolor, $balls, $extraballs);

$debug=$verbose;
$debug2=$verbose;

if ($csv) {
	csv();
	exit;
}
if ($NumbersToPick == "-?") { usage(); exit; }
if ($NumbersToPick < 1 or $NumbersToPick > 11 or $games <  1 or $balls < 1 or $balls > 100) { usage(); exit; }

if ( $winningnum ) {
	@wnn = split(/:/,$winningnum);
	print "Using WINNING NUMBER: [@wnn]\n";
}

#open(WINS, "numbers_take5-4.txt");
#$lines = csv(1);
#open(WINS, "$numfile");
#while (<WINS>) {
#	$lines++; 
#}
#close(WINS);

print "How many numbers: $NumbersToPick # of games: $games  # of balls: $balls\n";

srand(time|$$);  # Randomize the randomizer... as random as we need!

	@onerangemin=( 1,1, 2, 9, 15, 28 );
	#@onerangemin=( 1,1, 6, 11, 21, 30 );
	@onerangemax=( 1, 13, 23, 29, 35, 39 ); # Based upon spreadsheet calcs - last number is always max number.

###if (!$autolimits) {
###	@onerangemin=( 1,1, 2, 4, 9, 12 );
###	#@onerangemin=( 1,1, 6, 11, 21, 30 );
###	@onerangemax=( 1, 29, 37, 39, 42, 43 );
###	#@onerangemax=( 1,8, 20, 27, 36, 39 );
###	@tworangemin=( 1, 3, 6, 11, 23  );
###	@tworangemax=( 1, 48, 64, 73, 77 );
###	$ftrangemin=8+10;
###	$ftrangemax=103-30;
###	$ltrangemin=27+10;
###	$ltrangemax=123-10;
###	$sumrangemin=94-25;
###	$sumrangemax=94+20;
###}
###else {
	createarrays();
###}

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
	my $wnum;
        #($dt,$wnum) = split(/[\t| ]/,$y); Take5
        ($dt,@wnum) = split(/,/,$y);
        #chomp($wnum);
        #$cnums = $wnum;
	$cnums = join(",",@wnum);
        #@winner=split(/\,/,$cnums);
   @winner=@wnum;
   #$wdate=shift(@winner);
   #print "[$wdate][[@winner]]\n";
}

sub bynumber { $a <=> $b; }


sub getgame {
   $err=1;

   while ($err > 0 ) {
	   $cc++; # Iteration count

	$err=0; # This is set so if we DO get an error we keep looping here until we get a valid number that falls within the parameters

# Gen the 'unused' array of the numbers for use in - when a rand number is picked it is removed from this list so that it is not picked again
	foreach $i (1 .. $balls) {
		$s[$i]=$i;
		#print "s[i]= $s[$i]\n";
	}


# gen the rand number, if we get a zero keep trying, remove that number from our 'unused' array
	foreach $r (0 .. $NumbersToPick-1 ) {
	        do {
		   $k=int(rand($balls+1)-$r);
		   if ($debug) { print ("K=[$k] R=[$r] [numstopick=[$NumbersToPick] balls[$balls]\n"); }
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
	
	### We now have an array of N numbers which should be completely random and no dups.
	### Send this to the getsumdiffs to get sums diffs and total for our threes
        my @threesums, my @threediffs, my @rowsum;
        my ( $tsums, $tdiffs, $rwsm ) = &getsumdiffs(@ns);
        @threesums=@{$tsums}; @threediffs=@{$tdiffs}; @rowsum=@{$rwsm};
	my @current_num_calcs = [ [], [@threesums], [@threediffs], [@rowsum] ];  ## We put them into the same structure so we can iterate over them in an easier way

 	my $numcnt = @ns;
        my $numofthrees=$numcnt-2;  # So for a 5 number game this will be a set of three numbers

###  This is what we want to use... our autolimits to compare against our generated numbers
###		$colavg[$noa][$noc]=$cavg;
###             $colmax[$noa][$noc]=$cmax;
###             $colmin[$noa][$noc]=$cmin;
###     	$colavedev[$noa][$noc] = $avedev;
###             $stddev=sqrt($tmpsd/$lines);
###             $colstddev[$noa][$noc] = $stddev;
###

#	$rowcalcs[$lines] = [ [@snums], [ @threesums] , [ @threediffs], [@rowsum] ];

### We only need the outer most cols in the rowcalcs array
###
for ($noa=1; $noa<$aacc; $noa++) {   ### This should be the number of arrays ($aacc)-1 which it is! Yay!
            $tmpab=0; $tmpsd=0; $tmpad=0;
	    if ( $debug) { print ("outside array from rowcalcs -> $noa\n"); }
            for ($noc=0; $noc<@{$rowcalcs[1][$noa]}; $noc++) {   # For each item in each array
		$magichigh=$colavedev[$noa][$noc] + $colstddev[$noa][$noc] + $colavg[$noa][$noc];
		$magiclow=$colavg[$noa][$noc] - ($colavedev[$noa][$noc] + $colstddev[$noa][$noc]); 
                if ($debug) { print ("AveDev = [$colavedev[$noa][$noc]]  StdDev=[$colstddev[$noa][$noc] colsum=$colsum[$noa][$noc] -> $colsum[$noa][$noc] ColAvg=$colavg[$noa][$noc] High=$magichigh Lo=$magiclow ($current_num_calcs[0][$noa][$noc])\n"); }

		$cnc=$current_num_calcs[0][$noa][$noc];
		if ($cnc < $magiclow || $cnc > $magichigh ) { 
			$err=1; 
			if ($debug) { print ("ERROR ERROR ERROR!!!\n"); }
		}
###		print ("picked num calcs=[threesums]");
###		for ($not=0; $not<$numofthrees; $not++) { print ("$threesums[$not] "); }
###		print (" [threediffs]");
###		for ($not=0; $not<$numofthrees; $not++) { print ("$threediffs[$not] "); }
###		print ("rowsum=$rowsum[0]\n");
	    
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


# Gen our game number hash
foreach $gamenum (1 .. $games) {
	getgame();
	if ($debug)  { print "Got number[$gamenum] of [$games]:[  ---->>>   @ns   <<<---]\n"; }
	foreach $w (0 .. $NumbersToPick-1) {
	  $yg[$gamenum][$w]=$ns[$w];
        }
        if ( $extraball ) {
            $eb[$gamenum]=int(rand($extraball)+1);  # Last Super-Ball number - rand returns a number >= 0 and less than the value of EXPR¬¬
           }

  # pnums();
}

if ($debug) { print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"; }

# Print our numbers
foreach $uu (1 .. $games) {
	printf ("Got number[%02d] of [%d]:[  >>>   ",$uu,$games);
	foreach $w (0 .. $NumbersToPick-1) {
	$thisnum = $yg[$uu][$w];
	printf( " %2d ",$thisnum );
  }
   if ( $extraball ) {
     print "           Extraball = [$eb[$uu]]";
    }

  print "  <<<  ]\n";
}

### Print frqs
if ( $showfreqs ) {
	@numfreqsorted;
   for ($bc=1; $bc<=$balls; $bc++ ) {
       $ns = $numfreq[$bc]*1000+$bc;
       #$numfreqsorted[$ns] = $numfreq[$ns];  ## Here we put the actual number ($bc) in the sparse array and we will sort in reverse
       $numfreqsorted[$ns] = $numfreq[$bc];  ## Here we put the actual number ($bc) in the sparse array and we will sort in reverse
       #foreach my $bcs (sort { $a <=> $b } @numfreqsorted) {
       #foreach my $bcs ( @numfreqsorted) {
       #       if ( $bcs ) { print "$bcs\n";}
       #   }
       #print (" [[[# $bc]]]] -> Freq[$numfreq[$bc]] (((  $ns   )))\n");
	print ("$bc,Freq,@numfreq[$bc]\n");
   }
}
#print "And the WINNER IS.... ";
if ( $winningnum ) { 
	@winner = @wnn ; 
} else {
	#getgame();
	#@winner=@ns;
	print "Getting winner.... --->>> Winning #["; sleep(1);
	getwinner();
}
if ( $extraball ) { $powerball = pop(@winner); }
#pnums();
# Take FIVE Only getwinner();
print "@winner + Powerball=$powerball] \n";


#print "SUCKER!!!!\n";
$winnings=0;
$free=0;
$gameswon=0;
foreach $uu (1 .. $games) {
	$hits=0;
        $pbh=0;
        #if ($debug) { print ("Power = $eb[$uu] == $powerball\n" ); }
        if ($eb[$uu] == $powerball ) {
            if ($debug) { print ("POWERBALL HIT! = $powerball -> "); }
            $pbh=1;  ## Mark a hit for the PB because in Baloto we always win with any PB hit
        }
	foreach $e ( 0 .. $NumbersToPick-1 )  {
		foreach $q ( 0 .. $NumbersToPick-1 ) {
			#if ($debug) { print "Checking winning number $winner[$q] against $yg[$uu][$e]\n"; }
			if ( $winner[$q] == $yg[$uu][$e] ) {
				$hits++;
				$hh[$hits]=$yg[$uu][$e];
			}
		}
	}
        # print ("\nPBH=$pbh HITS=$hits");
	if ( $pbh == 1  ||  $hits > 2) { 
	print "GAME #[$uu]: ";
		$gameswon++;
		foreach $j ( 0 .. $NumbersToPick-1 ) {
			print "[$yg[$uu][$j]]";
		}
		print " - ";
		foreach $e ( 1 .. $hits) {
			print "($hh[$e])";
			$hh[$e]=0;
		}
                if ($pbh) { print ("  -> Power = $eb[$uu] == $powerball" ); }
		if (( $hits == 0 && $pbh ==1 ) || ($hits == 1 && $pbh ==1)) { print " - \$ ~5000 Pesos "; $winnings=$winnings+5000; }
		if ($hits == 2 ) { if ($debug) {print " - Nope! Not a win in Baloto"; $gameswon--;}}
		if ($hits == 2 && $pbh ==1 ) { print " - \$ ~10,000 Pesos "; $winnings=$winnings+10000; }
		if ($hits == 3 && $pbh ==0 ) { print " - \$ ~10,000 Pesos "; $winnings=$winnings+10000; }
		if ($hits == 3 && $pbh ==1 ) { print " - \$ ~40,000 Pesos "; $winnings=$winnings+40000; }
		if ($hits == 4 && $pbh ==0 ) { print " - \$ ~100,000 Pesos "; $winnings=$winnings+100000; }
		if ($hits == 4 && $pbh ==1 ) { print " - \$ ~1,000,000 Pesos "; $winnings=$winnings+1000000; }
		if ($hits == 5 && $pbh ==0 ) { print " - \$ ~50,000,000 Pesos "; $winnings=$winnings+50000000; }
		if ($hits == 5 && $pbh ==1 ) { print " - JackPot!!!!!!!!!!!!!!!!!!!!!! "; exit; }
		print "\n";

	}
}
$per=(($gameswon / $games)*100);
print "GamesWon=[$gameswon] - GamesPlayed=[$games] - PercentWon=[ $per ]\n";
print "WINNINGS: [$winnings]\n";

if ( $prcard ) {
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
