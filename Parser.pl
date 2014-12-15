#!/usr/bin/perl

package Parser;


require Scanner;


use strict;
use warnings;


# Forward declarations:
sub Error;
sub Term;
sub Power;
sub Factor;


sub Expr {
    my $INPUT = shift;
    &Term($INPUT);
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    while ($token eq "PLUS" || $token eq "MINUS") {
	&Term($INPUT);
	($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    }
    &Scanner::UngetToken($token);
}


sub Term {
    my $INPUT = shift;
    &Power($INPUT);
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    while ($token eq "TIMES" || $token eq "DIVIDED_BY") {
	&Power($INPUT);
	($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    }
    &Scanner::UngetToken($token);
}


sub Power {
    my $INPUT = shift;
    &Factor($INPUT);
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    if ($token ne "POWER") {
	&Scanner::UngetToken($token);
    } else {
	&Power($INPUT);
    }
}


sub Factor {
    my $INPUT = shift;
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    if ($token eq "NUMBER") {
	; # Intentionally empty!
    } elsif ($token eq "IDENT") {
	; # Intentionally empty!
    } elsif ($token eq "OPEN_PAREN") {
	&Expr($INPUT);
	($token, $value, $lineno) = &Scanner::GetToken($INPUT);
	$token eq "CLOSE_PAREN" || &Error("Expected ')' after expression on line $lineno, instead found $token!");
    } elsif ($token eq "PLUS" || $token eq "MINUS") {
	&Factor($INPUT);
    } else {
	&Error("Unexpected token $token($value) on line $lineno while parsing a factor!");
    }
}


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
    &Expr($INPUT);
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    if ($token ne "END_OF_INPUT") {
	&Error("Unexpected token $token($value) after end of expression on line $lineno: $token!");
    }
    close($INPUT);
}


&main();
