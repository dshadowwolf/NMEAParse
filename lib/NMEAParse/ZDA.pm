#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::ZDA;
our $VERSION = '0.0.1';
use Readonly;

sub process {
    my ( $xx, $self, @data ) = @_;
    Readonly my $DAY_LOC   => 1;
    Readonly my $MONTH_LOC => 2;
    Readonly my $YEAR_LOC  => 3;
    Readonly my $TZ_LOC    => 4;

    my $d = $self->{DATA};

    $d->{time_utc} = $data[0];
    $d->{date}
        = $data[$DAY_LOC]
        . qw/-/
        . $data[$MONTH_LOC]
        . qw/-/
        . $data[$YEAR_LOC];
    $d->{tz_hours} = $data[$TZ_LOC];
    $d->{time_utc} =~ s/(\d\d)(\d\d)(\d\d)/$1:$2:$3/gxms;
    return;
}

1;
