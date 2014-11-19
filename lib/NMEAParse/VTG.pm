#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::VTG;
our $VERSION = '0.0.1';

sub process {
    my ( $xx, $self, @data ) = @_;
    my $d = $self->{DATA};
    (   $d->{true_course},  undef,                $d->{mag_course},
        undef,              $d->{speed_in_knots}, undef,
        $d->{speed_in_kph}, undef,                $d->{mode}
    ) = @data;
    return;
}

1;
