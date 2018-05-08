#!/usr/bin/perl -w
#
use Getopt::Long;

$result = GetOptions (
 #"numfile:s" => \$hf, # string
 "lpr" => \$lpr,  # print to lpr default - need to be able to specify printer too - else we print to stdout
 "verbose" => \$verbose,
 "debug" => \$debug,
 "help|?|usage" => \$usage
);

#open(LP, ">/dev/lp0") || die "Cannot open LP0!\n";
# 
           #         1         2         3         4         5         6         7         8         9         0         1         2
           #123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
$ltp="0000000000000000000000000000"; # Left margin
#
# Take5 = insert card in direction of arrow:
# 	5 games per card
# 	39 number to print in a grid of 8 per row and 5 per col
# 	bottom corner / last number would be 40 but is blank for this game (bottom left of each game area)
#	Each game Grid looks like this:
#
#	^^^ Insert ^^^^
#
#	36 31 26 21 16 11  6 1
#	37 32 27 22 XX XX  7 2
#	38 33 28 23 XX XX  8 3
#	39 34 29 24 XX XX  9 4
#	   35 30 25 XX XX 10 5
#
# We have to games per row and X rows per game
# Y games is our driving number. 
# First row is '01 11 21 31 41 51' for lotto
# 2nd   row is '02 12 22 32 42 52'
# But can't we figure this out by knowing # of #'s and rows?  Or course we can!
#&MvYRel(1);
#
# Number of Numbers per row = $nn
while ( $games = <> ) {
	print "$games\n";
	$games2=<>;
	print "GAMES2: $games2\n";
}
exit;

############# Initialize printer:

&resetp;
&resetp;
&Direction(0);
&GraphicsMode(1);
&Resolution(360);
&MvYRel(60);
&color();

#############

#for ($cr=0; $cr<59 ; $cr++ ) {
	#    for ($nn=0; $nn<6 ; $nn++ ) {
	for ($cc=0; $cc<16; $cc++) {
	&PrintLeftMargin();
	&printline("000000001111111000000000000111111",1080,1);
	printf  ("%c" , 0x0d);
	&MvYRel(1);
}
            #         1         2         3         4
#&MvYRel(1);#1234567890123456789012345678901234567890123456789012345678901234 
#&printline("1111111111110000000000001111111111110010110010000000000011111111",1080,1);
#print LP "\f";

&resetp;
print "\f";
#close(LP);
exit();

sub PrintLeftMargin {
	&printline("000000000000000000000000000000000000000000000000000000000000000000000000000",1080,1);
}

sub GraphicsMode {
local ($mode) = @_;
# Select graphics mode
#print "Entering graphics mode... ($mode)\n";
printf  ("%c%c%c%c%c%c" , 0x1b , 0x28 , 0x47, 0x01, 0x00, $mode);
}

sub resetp {
#print "Resetting printer...\n";
printf  ( "%c%c", 0x1b , 0x40);
}

sub Direction {
local ($m) = @_;
$mode=int($m);
#print "Setting direction mode... ($mode)\n";
printf  ( "%c%c%c", 0x1b , 0x55, $mode );
}

sub MvYRel {
local ($d) = @_;
$dist=int($d);
#print "Moving [$dist] along Y...\n";
$dh=int($dist/256);
$dl=$dist%256;
printf   ( "%c%c%c%c%c%c%c", 0x1b , 0x28, 0x76, 0x02, 0x0 , $dl, $dh );
#print "Moving dh=[$dh] dl=[$dl]\n";
}

sub color {
	printf ( "%c%c%c%c", 0x1b, 0x72, 0x0, 0x0d);
}

sub printline {
	local ($LineToPrint, $BitCount, $NumRows) = @_;
	#print ("LineToPrint [$LineToPrint], Bit Count=[$BitCount]\n");
	if ($BitCount > 2880 ) { $BitCount=2880; }
	$bitshi =int($BitCount/256);
	$bitslo =int($BitCount%256);
	# x res dpi = 3600/xres_dpi = 360
	$xres_dpi=10; 
	# y res dpi = 3600/yres_dpi = 360
	$yres_dpi=10; 
	#$NumRows=1; # This really should be the number of rows we are sending!!

	#  $t is number of bytes we are sending and the printer is expecting(?)
	$BytesPerLine=int((($bitshi*256)+$bitslo+7)/8);
	#$t=int(($NumRows)*int((($bitshi*256)+$bitslo+7))/8); 

	#print ("Printing: [$LineToPrint] BitCount:[$BitCount] bitslo=[$bitslo] bitshi=[$bitshi]\n");
	#print ("          Xres_dpi=[$xres_dpi] Yres_dpi=[$yres_dpi] BytesPerLine=[$BytesPerLine] \n");

	printf  ("%c%c%c%c%c%c%c%c", 0x1b, 0x2e, 0x0 , $xres_dpi, $yres_dpi, $NumRows, $bitslo, $bitshi);

	$ll=length($LineToPrint); # $ll should equal $$BytesPerLine if we did our calcs right but if not then adjust

	for ($i2=0; $i2<$NumRows; $i2++) { # So print the pattern $NumRows times
	    for ($k=0; $k<$ll && $k<$BytesPerLine ; $k++) { # Now how many rows of this pattern do we want?
		    #$ss=substr($LineToPrint,$k,1);
		    #    	print ("K=[$k] L=[$ll] LTP[$ss]");
		if (substr($LineToPrint,$k,1)=='0') {
			printf  ("%c", 0x0);
		} else {
			printf  ("%c", 0xff);
		}
	    }
	    for ($k=$BytesPerLine;$k>$ll;$k--) {
		#	print ("K=[$k] L=[$ll]");
		printf  ("%c", 0x0 );
	    }
	    #	printf  ("%c" , 0x0d);
	}
}

sub Resolution {
	local ($r) = @_;
	$res=3600/int($r);
	printf  ("%c%c%c%c%c%c", 0x1b , 0x28, 0x55, 1, 0 , $res);
	#print "Set resolution to [$res]\n";
}
