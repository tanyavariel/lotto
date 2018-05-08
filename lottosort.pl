#!/usr/bin/perl

$file = $ARGV[0];
$dlim = $ARGV[1];

if ( ! $dlim ) { $dlim = '\t'; }

sub bynumber { $a <=> $b; }

open(F, $file) || die "Cannot open $file\n";
	while ($y=<F>) {
		chop($y);
#print "[$y]\n";
		@ww=split(/$dlim/,$y);
#print "--->>> [@ww]\n";
		$dt=shift(@ww);
#print "--->>> [$dt]\n";
		$pb=pop(@ww);

#print "--->>> Powerball [$pb]\n";
		@ds = sort bynumber @ww;
		print "$dt @ds $pb\n";
}

#print "<hr>";
#print "</body>\n";
#while (($key, $val) = each %ENV) {
#	print "$key = $val<BR>\n";
#}

