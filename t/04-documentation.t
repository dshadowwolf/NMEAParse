#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
BEGIN {
  eval "use Test::Pod 1.00";
  plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
  plan tests => 1;
  pod_file_ok( 'lib/NMEAParse.pm', "Does POD checkout and validate" );
}

