#!/usr/bin/perl

$nn = $ARGV[0];
$tt = $ARGV[1];

#print "Iterations: $tt\n";
sub bynumber { $a <=> $b; }

#print "Content-type: text/html\n\n";
#print "<BODY
#  BGCOLOR=#343434
#  TEXT=#eeffee
#  LINK=#000020
#  VLINK=#000080
#  ALINK=#FF0000";
#print "<h1>lotto Page</h1>";
#print "<hr>";
sub getgame {
   $err=1;

   while ($err != 0 ) {

	foreach $i (1 .. 59) {
		$s[$i]=$i;
		#print "s[i]= $s[$i]\n";
	}

	foreach $r (1 .. $nn ) {
		$k=int(rand(60-$r)+1);
		$n2[$r]=$s[$k];
		if ($debug)  { print "$n2[$r]=$s[$k] - "; }
		foreach $t ($k .. 59-$r) {
			$s[$t]=$s[$t+1];
		}
	}
	
	if ($debug)  { print "LOTTO #: "; }
	@ns = sort bynumber @n2;
	if ($debug)  { print "SORTED:[@ns] "; }
	foreach $nf (1 .. $nn) {
		#$n[$cc][$nf] = $ns[$nf];
		if ($debug)  { print "$ns[$nf] "; }
		$sum=$sum+$ns[$nf];
	}
	if ($debug) { print "\n"; }


	$a1=$ns[1]+$ns[2]+$ns[3];
	$a2=$ns[4]+$ns[5]+$ns[6];
	$b1=$ns[1]+$ns[2];
	$b2=$ns[3]+$ns[4];
	$b3=$ns[5]+$ns[6];

	if ($debug) { print "SUM=[$sum]  -  1st3[$a1] 2nd3[$a2]  -  1st2[$b1] 2nd2[$b2] 3rd2[$b3]\n"; }

	$err=0;

	#if ( $sum < 94 or $sum > 256 ) {
	if ( $sum < 70 or $sum > 256 ) {
		if ($debug)  { print "SUM Out of range (94 - 256): $sum\n"; }
		$err=1;
	}
	#if ( $a1 <16 or $a1 > 96 ) {
	if ( $a1 <6 or $a1 > 96 ) {
		if ($debug)  { print "1st three out of range (16 - 96): $a1\n"; }
		$err=1;
	}
	if ( $a2 < 77 or $a2 > 165 ) {
		if ($debug)  { print "2nd three out of range (77 - 165): $a2\n"; }
		$err=1;
	}
	if ( $b1 < 3 or $b1 > 52 ) {
		if ($debug)  { print "1st two out of range (3 - 52): $b1\n"; }
		$err=1;
	}
	if ( $b2 < 26 or $b2 > 95 ) {
		if ($debug)  { print "2nd two out of range (26 - 95): $b2\n"; }
		$err=1;
	}
	if ( $b3 < 57 or $b3 > 116 ) {
		if ($debug)  { print "3rd two out of range (57 - 116): $b3\n"; }
		$err=1;
	}
	if ($debug) { print "ERR[$err] iteration:[$cc < $tt]\n";
		print "=================================\n";
	}
	$sum=0;
	if ($debug) { sleep (2); }
   } # redo on error loop

} # done with Sub getgame

getgame();
@bg=@ns;
pnums();
foreach $uu (1 .. $tt) {
	getgame();
	pnums();
}


sub pnums {
	foreach $q ( 1 .. $nn ) {
		printf ("%02d",$ns[$q]);
		if ($q < $nn) { print ","; }
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
