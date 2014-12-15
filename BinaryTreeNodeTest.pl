#!/usr/bin/perl

use BinaryTreeNode;


use strict;
use warnings;



sub Error() {
    my $msg = shift;
    print "$0: $msg\n";
    exit 1;
}


my $left_child = &BinaryTreeNode::CreateLeaf("lc");
my $right_child = &BinaryTreeNode::CreateLeaf("rc");
my $parent = &BinaryTreeNode::Create($left_child, $right_child, "parent");
my $grandchild = &BinaryTreeNode::CreateLeaf("gc");
&BinaryTreeNode::SetLeftSubtree($right_child, $grandchild);

&BinaryTreeNode::IsLeaf($left_child) || &Error("Left child must be a leaf node!");
&BinaryTreeNode::IsLeaf($grandchild) || &Error("Grandchild must be a leaf node!");
&BinaryTreeNode::IsLeaf($right_child) && &Error("Right child must not be a leaf node!");
&BinaryTreeNode::IsLeaf($parent) && &Error("Parent must not be a leaf node!");
 
&BinaryTreeNode::GetLeftSubtree($parent) == $left_child || &Error("Left subtree must equal left child!");
&BinaryTreeNode::GetRightSubtree($parent) == $right_child || &Error("Right subtree must equal left child!");

&BinaryTreeNode::GetValue($parent) eq "parent" || &Error("Parent's value must be \"parent\"!");
&BinaryTreeNode::GetValue($left_child) eq "lc" || &Error("Left child's value must be \"lc\"!");
&BinaryTreeNode::GetValue($right_child) eq "rc" || &Error("Left child's value must be \"rc\"!");

&BinaryTreeNode::PrintTree($parent);
