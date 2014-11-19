#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::GSA;
our $VERSION = '0.0.1';

sub process {
    my ( $xx, $self, @data ) = @_;
    my $d = $self->{DATA};
    (   $d->{auto_man_D}, $d->{dimen},  $d->{prn01a}, $d->{prn02a},
        $d->{prn03a},     $d->{prn04a}, $d->{prn05a}, $d->{prn06a},
        $d->{prn07a},     $d->{prn08a}, $d->{prn09a}, $d->{prn10a},
        $d->{prn11a},     $d->{prn12a}, $d->{pdop},   $d->{hdop},
        $d->{vdop}
    ) = @data;

    return;
}

1;
