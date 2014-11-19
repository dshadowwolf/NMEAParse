#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
      use_ok('NMEAParse') || print "Bail out!\n";
}

my $nmeaparser = NMEAParse->new();

diag( "Testing NMEAParse $NMEAParse::VERSION, Perl $], $^X" );
