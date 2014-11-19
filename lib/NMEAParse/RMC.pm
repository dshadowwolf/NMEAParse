#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::RMC;
our $VERSION = '0.0.1';

sub process {
    my ( $xx, $self, @data ) = @_;
    my $d = $self->{DATA};
    (   $d->{time_utc},          $d->{data_valid},
        $d->{lat_ddmm},          $d->{lat_NS},
        $d->{lon_ddmm},          $d->{lon_EW},
        $d->{speed_over_ground}, $d->{course_made_good},
        $d->{ddmmyy},            $d->{mag_var},
        $d->{mag_var_EW}
    ) = @data;

    $d->{time_utc} =~ s/(\d\d)(\d\d)(\d\d)/$1:$2:$3/gxms;

    return;
}

1;
