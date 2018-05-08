#!/usr/bin/perl
#
#open(LP, ">/dev/lp0") || die "Cannot open LP0!\n";
# exit packet mode
#print LP "\x00\x00\x00\x1b\x01\x40\x45\x4a\x4c\x20\x31\x32\x38\x34\x2e\x34\x0a\x40\x45\x4a\x4c\x20\x20\x20\x20\x20\x0a";
# 
&resetp;
#print "\033r0Hello Tony\n";
&GraphicsMode(1);
&Direction(0);
&Resolution(360);
&MvYRel(300);
&printline("hello",360);

#print LP "\f";
&resetp;
#close(LP);

sub GraphicsMode {
local ($mode) = int(@_);
# Select graphics mode
#print "Entering graphics mode... ($mode)\n";
printf  ("%c%c%c%c%c%c" , 27 , '0x28' , '0x47', '0x01', '0x00', '0x01');
}

sub resetp {
#print "Resetting printer...\n";
printf  ( "%c%c", 0x1b , '@');
}

sub Direction {
local ($mode) = int(@_);
#print "Setting direction mode... ($mode)\n";
printf  ( "%c%c%c", 27 , 'U', $mode );
}

sub MvYRel {
local ($d) = @_;
$dist=int($d);
#print "Moving [$dist] along Y...\n";
$dh=int($dist/256);
$dl=$dist%256;
printf   ( "%c%c%c%c%c%c%c", 27 , '(', 'v', '2', '0', $dh, $dl );
#print "Moving dh=[$dh] dl=[$dl]\n";
}

sub printline {
	local ($LineToPrint, $BitCount) = @_;
	if ($BitCount > 2880 ) { $BitCount=2880; }
	$bitslo =int($BitCount%256);
	$bitshi =int($BitCount/256);
	# x res dpi = 3600/xres_dpi = 360
	$xres_dpi=10; 
	# y res dpi = 3600/yres_dpi = 360
	$yres_dpi=10; 
	$NumRows=1;
	$t=int($NumRows)*int((($bitshi*256)+$bitslo+7)/8);
	#print ("Printing: [$LineToPrint] BitCount:[$BitCount] bitslo=[$bitslo] bitshi=[$bitshi]\n");
	#print ("          Xres_dpi=[$xres_dpi] Yres_dpi=[$yres_dpi] T=[$t] \n");

	printf  ("%c%c%c%c%c%c%c%c", 27, '.', 0 , $xres_dpi, $yres_dpi, $NumRows, $bitslo, $bitshi);

	foreach $i ( 1 .. 64) {
		for ($k=1, $k<=64, $k++) {
			printf  ("%c", $i);
		}
	}
	printf  ("%c" , '0xd');
}

sub Resolution {
	local ($r) = @_;
	$res=3600/int($r);
	printf  ("%c%c%c%c%c%c", 27 , '(', 'U', 1, 0 , 10);
	#print "Set resolution to [$res]\n";
}
