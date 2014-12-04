#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::GLL;
our $VERSION = '0.0.2';

sub process {
    my ( $x, $self, @data ) = @_;
    my $d    = $self->{DATA};
    (   $d->{lat_ddmm_low}, $d->{lat_NS},   $d->{lon_ddmm_low},
        $d->{lon_EW},       $d->{time_utc}, $d->{data_valid}
    ) = @data;

    return;
}

1;
