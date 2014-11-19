#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use NMEAParse;

plan tests => 2;

BEGIN {
      my $nm = NMEAParse->new( 'GGA','GLL' );
      my @funcs = ( 'GGA','GLL' );
      can_ok( $nm, @funcs );
      ok( ! defined $nm->can('RMC'), 'Method not requested was not loaded' );
}

