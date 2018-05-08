#!/usr/bin/perl -w
# Change above line to path to your perl binary

use GD;

# Create a new image
$im = new GD::Image(380,1100);

# Allocate some colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,0,0);
$blue = $im->colorAllocate(0,0,255);
$green = $im->colorAllocate(0,255,0);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Put a black frame around the picture
#$im->rectangle(0,0,379,1099,$black);
# Print marker so we know which way to put card in
$im->line(50,50,60,60,$red);
$im->line(70,50,60,60,$red);
$games=4;

$rectwidth=16;
$recthi=7;
$blockwidthspacing=32;
$blockhispacing=21;
$gamespace=30;

$sul=56;
$sll=461;
$sbr=$sul+$rectwidth;
$sur=$sll+$recthi;
# First fill for take5 card...
# Game # 1 Row 1 - numbers 36,31,26,21,16,11,6,1
for ($ng=$games; $ng>-1; $ng--) {
  
  for ($row=0;$row<=4;$row++) {
   for ($i=0;$i<=7;$i++) {
   $im->filledRectangle($sul+($blockwidthspacing*$i),$sll+($blockhispacing*$row),$sbr+($blockwidthspacing*$i),$sur+($blockhispacing*$row),$black);
   }
  }
$sll=$sll+($blockhispacing*$row)+$gamespace;
$sur=$sur+($blockhispacing*$row)+$gamespace;
print "[$sll]";
}

# Draw a blue oval
#$im->arc(50,50,55,75,0,360,$blue);
#$im->arc(50,50,95,75,0,360,$green);

# And fill it with red
#$im->fill(50,50,$red);

# Open a file for writing 
open(PICTURE, ">gd-take5.jpeg") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->jpeg(100);
#print PICTURE $im->png;
close PICTURE;
#$png_data = $im->png;
# open (DISPLAY,"| display -") || die;
#        binmode DISPLAY;
#        print DISPLAY $png_data;
#        close DISPLAY;
