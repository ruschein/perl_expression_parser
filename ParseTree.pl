#!/usr/bin/perl

package ParseTree;


use strict;
use warnings;
use Scanner;
use BinaryTreeNode;


# Forward declarations:
sub Error;
sub Term;
sub Power;
sub Factor;


sub Expr {
    my $INPUT = shift;
    my $expr_node = &Term($INPUT);
    for (;;) {
	my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
	if ($token ne "PLUS" && $token ne "MINUS") {
	    &Scanner::UngetToken($token);
	    return $expr_node;
	}

	my $right_node = &Term($INPUT);
	my $operator = $token eq "PLUS" ? "+" : "-";
	$expr_node = &BinaryTreeNode::Create($expr_node, $right_node, $operator);
    }
}


sub Term {
    my $INPUT = shift;
    my $term_node = &Power($INPUT);
    for (;;) {
	my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
	if ($token ne "TIMES" && $token ne "DIVIDED_BY") {
	    &Scanner::UngetToken($token);
	    return $term_node;
	}

	my $right_node = &Power($INPUT);
	my $operator = $token eq "TIMES" ? "*" : "/";
	$term_node = &BinaryTreeNode::Create($term_node, $right_node, $operator);
    }
}


sub Power {
    my $INPUT = shift;
    my $left_factor_node = &Factor($INPUT);
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    if ($token ne "POWER") {
	&Scanner::UngetToken($token);
	return $left_factor_node;
    }
    my $right_factor_node = &Power($INPUT);
    return &BinaryTreeNode::Create($left_factor_node, $right_factor_node, "^");
}


sub Factor {
    my $INPUT = shift;
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    if ($token eq "NUMBER") {
	return &BinaryTreeNode::CreateLeaf($value);
    } elsif ($token eq "IDENT") {
	return &BinaryTreeNode::CreateLeaf($value);
    } elsif ($token eq "OPEN_PAREN") {
	my $expr_node = &Expr($INPUT);
	($token, $value, $lineno) = &Scanner::GetToken($INPUT);
	$token eq "CLOSE_PAREN" || &Error("Expected ')' after expression on line $lineno, instead found $token!");
	return $expr_node;
    } elsif ($token eq "PLUS" || $token eq "MINUS") {
	return &Factor($INPUT);
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
    my $root_node = &Expr($INPUT);
    my ($token, $value, $lineno) = &Scanner::GetToken($INPUT);
    $value = "undefined" if !defined($value);
    if ($token ne "END_OF_INPUT") {
	&Error("Unexpected token $token($value) after end of expression on line $lineno: $token!");
    }
    &BinaryTreeNode::PrintTree($root_node);
    close($INPUT);
}


&main();
