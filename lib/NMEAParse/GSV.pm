#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse::GSV;
our $VERSION = '0.0.1';
use Readonly;
use Carp qw/carp croak/;

sub process {
    my ( $xx, $self, @data ) = @_;
    Readonly my $SS => 3;
    my $d = $self->{DATA};

    my $sentence = $data[1];

    if ( $sentence == 1 ) {
        (   $d->{num_sentences}, $d->{sentence},  $d->{num_sat_vis},
            $d->{prn01},         $d->{elev_deg1}, $d->{az_deg1},
            $d->{sig_str1},      $d->{prn02},     $d->{elev_deg2},
            $d->{az_deg2},       $d->{sig_str2},  $d->{prn03},
            $d->{elev_deg3},     $d->{az_deg3},   $d->{sig_str3},
            $d->{prn04},         $d->{elev_deg4}, $d->{az_deg4},
            $d->{sig_str4}
        ) = @data;

    }
    elsif ( $sentence == 2 ) {
        (   $d->{num_sentences}, $d->{sentence},  $d->{num_sat_vis},
            $d->{prn05},         $d->{elev_deg5}, $d->{az_deg5},
            $d->{sig_str5},      $d->{prn06},     $d->{elev_deg6},
            $d->{az_deg6},       $d->{sig_str6},  $d->{prn07},
            $d->{elev_deg7},     $d->{az_deg7},   $d->{sig_str7},
            $d->{prn08},         $d->{elev_deg8}, $d->{az_deg8},
            $d->{sig_str8}
        ) = @data;

    }
    elsif ( $sentence == $SS ) {
        (   $d->{num_sentences}, $d->{sentence},   $d->{num_sat_vis},
            $d->{prn09},         $d->{elev_deg9},  $d->{az_deg9},
            $d->{sig_str9},      $d->{prn10},      $d->{elev_deg10},
            $d->{az_deg10},      $d->{sig_str10},  $d->{prn11},
            $d->{elev_deg11},    $d->{az_deg11},   $d->{sig_str11},
            $d->{prn12},         $d->{elev_deg12}, $d->{az_deg12},
            $d->{sig_str12}
        ) = @data;
    }
    return;
}

1;
