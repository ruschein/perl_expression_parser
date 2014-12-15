#!/usr/bin/perl

package BinaryTreeNode;


use strict;
use warnings;


# Binary tree nodes are represented as arrays with 3 elements.
# The 0th element is the left subtree, the 1st element the right
# subtree and the 2nd element the node's value.


# Call with ($left_subtree, $right_subtree, $value).
sub Create {
    my $left_subtree = shift;
    my $right_subtree = shift;
    my $value = shift;
    return [$left_subtree, $right_subtree, $value];
}


# Call with ($value).
sub CreateLeaf {
    my $value = shift;
    return &Create(undef, undef, $value);
}


sub IsLeaf {
    my $node_ref = shift;
    return !defined(@$node_ref[0]) && !defined(@$node_ref[1]);
}


sub GetValue {
    my $node_ref = shift;
    return @$node_ref[2];
}


sub GetLeftSubtree {
    my $node_ref = shift;
    return @$node_ref[0];
}


sub GetRightSubtree {
    my $node_ref = shift;
    return @$node_ref[1];
}


# Call with ($node, $new_left_subtree).  Returns the modified node.
sub SetLeftSubtree {
    my $node_ref = shift;
    my $new_left_subtree = shift;
    @$node_ref[0] = $new_left_subtree;
    return $node_ref;
}


# Call with ($node, $new_right_subtree).  Returns the modified node.
sub SetRightSubtree {
    my $node_ref = shift;
    my $new_right_subtree = shift;
    @$node_ref[0] = $new_right_subtree;
    return $node_ref;
}


# Call with root node.
sub PrintTree {
    my $node_ref = shift;
    my $indent = shift || "  ";
    defined(@$node_ref[1]) && &PrintTree(@$node_ref[1], $indent . "  ");
    print $indent . @$node_ref[2] . "\n";
    defined(@$node_ref[0]) && &PrintTree(@$node_ref[0], $indent . "  ");
}


1;
