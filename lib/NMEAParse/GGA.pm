#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::GGA;
our $VERSION = '0.0.2';

sub process {
    my ( $x, $self, @data ) = @_;
    my $d = $self->{DATA};
    (   $d->{time_utc},                   $d->{lat_ddmm},
        $d->{lat_NS},                     $d->{lon_ddmm},
        $d->{lon_EW},                     $d->{fixq012},
        $d->{num_sat_tracked},            $d->{hdop},
        $d->{alt_meters},                 $d->{alt_meters_units},
        $d->{height_above_wgs84},         $d->{height_units},
        $d->{sec_since_last_dgps_update}, $d->{dgps_station_id}
    ) = @data;
    if ( $d->{time_utc} ) {
        $d->{time_utc} =~ s/(\d\d)(\d\d)(\d\d)/$1:$2:$3/gxms;
    }
    return;
}

1;
