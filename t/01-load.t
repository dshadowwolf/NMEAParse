#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 2;

BEGIN {
      use_ok('NMEAParse');
      require_ok('NMEAParse');
}
