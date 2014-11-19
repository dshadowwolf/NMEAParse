#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use NMEAParse;

plan tests => 1;

BEGIN {
      my $nm = NMEAParse->new( 'GGA','GLL' );
      my @funcs = ( 'GGA','GLL' );
      can_ok( $nm, @funcs );
}

