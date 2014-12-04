#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::GLL;
our $VERSION = '0.0.1';

sub process {
    shift;
    my $self = shift;
    my @data = shift;
    my $d    = $self->{DATA};
    (   $d->{lat_ddmm_low}, $d->{lat_NS},   $d->{lon_ddmm_low},
        $d->{lon_EW},       $d->{time_utc}, $d->{data_valid}
    ) = @data;

    require Data::Dumper;
    print Data::Dumper->Dumper( @data ) . "\n";
    
    return;
}

1;
