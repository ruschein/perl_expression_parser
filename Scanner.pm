#!/usr/bin/perl

package Scanner;


use strict;
use warnings;


use constant {
    PLUS         => "PLUS",
    MINUS        => "MINUS",
    TIMES        => "TIMES",
    DIVIDED_BY   => "DIVIDED_BY",
    POWER        => "POWER",
    OPEN_PAREN   => "OPEN_PAREN",
    CLOSE_PAREN  => "CLOSE_PAREN",
    NUMBER       => "NUMBER",
    IDENT        => "IDENT",
    END_OF_INPUT => "END_OF_INPUT",
    UNKNOWN      => "UNKNOWN",
};


sub IsDigit {
    my $ch = shift;
    return defined($ch) && ($ch =~ m/^\d$/);
}


# Only call this if there is at least a single digit next in the input stream!
sub ReadDigitSequence {
    my $INPUT = shift;
    my $digits = $INPUT->getc();
    my $ch;
    while (1) {
	$ch = $INPUT->getc();
	if (&IsDigit($ch)) {
	    $digits .= $ch;
	} else {
	    $INPUT->ungetc(ord($ch)) if defined($ch);
	    return $digits;
	}
    }
}


# Only call this if there is at least a single digit next in the input stream!
sub ReadFloat {
    my $INPUT = shift;
    my $number = &ReadDigitSequence($INPUT);
    my $ch = $INPUT->getc();
    return $number if !defined($ch);

    if ($ch ne ".") {
	$INPUT->ungetc(ord($ch));
	return $number;
    }
    $number .= ".";

    $ch = $INPUT->getc();
    if (!IsDigit($ch)) {
	$INPUT->ungetc(ord($ch)) if defined($ch);
	return $number;
    }
    $INPUT->ungetc(ord($ch));

    $number .= &ReadDigitSequence($INPUT);
    $ch = $INPUT->getc();
    if ($ch ne 'e' && $ch ne 'E') {
	$INPUT->ungetc(ord($ch)) if defined($ch);
	return $number;
    }
    $number .= $ch;

    $ch = $INPUT->getc();
    if ($ch ne '+' && $ch ne '-' && !IsDigit($ch)) {
	$number .= $ch if defined($ch);
	return $number;
    }
    if ($ch eq "+" || $ch eq "-") {
	$number .= $ch;
	$ch = $INPUT->getc();
    }

    if (!IsDigit($ch)) {
	return $number;
    }
    $INPUT->ungetc(ord($ch));
    $number .= &ReadDigitSequence($INPUT);

    return $number;
}


# Tests its string argument as to it being a valid string representation of a floating point number.
sub LooksLikeValidFloatingPointNumber {
    my $possible_number = shift;
    return $possible_number =~ m/^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/;
}


# Idents must start with a letter and can then be followed by zero or more letters or underscores.
sub ReadIdent {
    my $INPUT = shift;
    my $ident = "";
    my $ch = $INPUT->getc();
    while (defined($ch) && $ch =~ m/[a-zA-Z_]/) {
	$ident .= $ch;
	$ch = $INPUT->getc();
    }

    $INPUT->ungetc(ord($ch)) if defined($ch);
    return $ident;
}


{
    my $lineno = 1; # Current line number for error messages.
    my $last_token;
    my $last_value;
    my $last_lineno;

    sub UngetToken {
	defined($last_token) && die("in Scanner::UngetToken: attempt to unget tokens twice in a row!");
	$last_token = shift;
    }

    sub GetToken {
	if (defined($last_token)) {
	    my $temp = $last_token;
	    $last_token = undef;
	    return ($temp, $last_value, $last_lineno);
	}

	my $INPUT = shift;
	my $ch;

	# Skip leading whitespace:
	do {
	    $ch = $INPUT->getc();
	    if (!defined($ch)) {
		$last_lineno = $lineno;
		$last_value = undef;
		return (END_OF_INPUT, undef,  $lineno);
	    } elsif ($ch eq "\n") {
		++$lineno;
	    }
	} while ($ch =~ m/[\s\v]/);

	$last_lineno = $lineno;
	$last_value = undef;
	$ch eq "+" && return (PLUS, undef, $lineno);
	$ch eq "-" && return (MINUS, undef, $lineno);
	$ch eq "*" && return (TIMES, undef, $lineno);
	$ch eq "/" && return (DIVIDED_BY, undef, $lineno);
	$ch eq "^" && return (POWER, undef, $lineno);
	$ch eq "(" && return (OPEN_PAREN, undef, $lineno);
	$ch eq ")" && return (CLOSE_PAREN, undef, $lineno);

	if ($ch =~ m/[a-zA-Z]/) {
	    $INPUT->ungetc(ord($ch));
	    my $ident = &ReadIdent($INPUT);
	    return (IDENT, $ident, $lineno);
	}

	if (!&IsDigit($ch)) {
	    $last_value = $ch;
	    return (UNKNOWN, $ch, $lineno);
	}

	$INPUT->ungetc(ord($ch));
	my $number = &ReadFloat($INPUT);
	$last_value = $number;
	return (LooksLikeValidFloatingPointNumber($number) ? NUMBER : UNKNOWN, $number,  $lineno);
    }
}


1;
