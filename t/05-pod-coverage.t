#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Pod::Coverage;

plan tests => 1;

BEGIN {
  my $pc = Pod::Coverage->new( package => 'NMEAParse' );
  is( $pc->coverage, 1, "Pod Coverage test" );
}