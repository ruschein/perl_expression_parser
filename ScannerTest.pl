#!/usr/bin/perl

require Scanner;

use strict;
use warnings;


sub Usage() {
    print "usage: $0 input_filename\n";
    exit 1;
}


sub Error() {
    my $msg = shift;
    print "$0: $msg\n";
    exit 1;
}


sub main() {
    $#ARGV == 0 || Usage();
    open(my $INPUT, "<", $ARGV[0]) || &Error("Can't open \"$ARGV[0]\" for reading ($!)!");
    while (my ($token, $value, $lineno) = &Scanner::GetToken($INPUT)) {
	if ($token eq "END_OF_INPUT") {
	    close($INPUT);
	    exit 0;
	} elsif ($token eq "NUMBER") {
	    print "NUMBER($value)\n";
	} elsif ($token eq "UNKNOWN") {
	    print "UNKNOWN($value) on line $lineno\n";
	    close($INPUT);
	    exit 1;
	} else {
	    print "$token\n";
	}
    }
}


&main();
