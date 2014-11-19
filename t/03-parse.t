#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use NMEAParse;
use open ':encoding(utf8)';

plan tests => 1;

BEGIN {
    my $nm
        = NMEAParse->new( 'GGA', 'GLL', 'GSA', 'GSV', 'RMC', 'VTG', 'ZDA' );
    open my $f, "<t/test_data.nmea" or die "Cannot open input file: $!";

    for my $line (<$f>) {
        $nm->parse($line);
    }

    my %expected = (
        'sig_str2'                   => '24',
        'az_deg3'                    => '052',
        'prn03a'                     => '24',
        'elev_deg5'                  => '36',
        'prn09'                      => '22',
        'prn08'                      => '24',
        'elev_deg3'                  => '44',
        'elev_deg2'                  => '55',
        'elev_deg4'                  => '40',
        'mag_var_EW'                 => '',
        'lat_ddmm_low'               => '3912.4397',
        'mag_course'                 => '',
        'prn03'                      => '26',
        'prn06'                      => '48',
        'elev_deg1'                  => '79',
        'az_deg11'                   => '029',
        'prn06a'                     => '15',
        'az_deg12'                   => undef,
        'prn10'                      => '27',
        'az_deg2'                    => '311',
        'az_deg6'                    => '240',
        'sig_str6'                   => '39',
        'elev_deg9'                  => '05',
        'prn10a'                     => '',
        'fixq012'                    => '2',
        'prn04a'                     => '18',
        'prn07a'                     => '26',
        'az_deg10'                   => '329',
        'lon_ddmm_low'               => undef,
        'mag_var'                    => '',
        'elev_deg11'                 => '01',
        'sec_since_last_dgps_update' => '0000',
        'sig_str11'                  => '16',
        'height_units'               => 'M',
        'dimen'                      => '3',
        'mode'                       => 'D',
        'speed_in_knots'             => '0.03',
        'num_sat_vis'                => '11',
        'course_made_good'           => '121.37',
        'prn02'                      => '21',
        'sig_str3'                   => '35',
        'time_utc'                   => '20:15:51.000',
        'az_deg7'                    => '072',
        'speed_in_kph'               => '0.06',
        'prn02a'                     => '21',
        'sentence'                   => '3',
        'elev_deg12'                 => undef,
        'sig_str7'                   => '28',
        'prn05'                      => '29',
        'num_sentences'              => '3',
        'az_deg1'                    => '130',
        'az_deg9'                    => '266',
        'lat_ddmm'                   => '3912.4397',
        'prn01a'                     => '05',
        'prn01'                      => '15',
        'dgps_station_id'            => '0000',
        'lon_EW'                     => 'W',
        'prn08a'                     => '',
        'sig_str9'                   => '18',
        'height_above_wgs84'         => '-33.3',
        'lon_ddmm'                   => '08427.5741',
        'az_deg5'                    => '204',
        'prn11a'                     => '',
        'prn09a'                     => '',
        'hdop'                       => '1.19',
        'elev_deg10'                 => '03',
        'sig_str12'                  => undef,
        'az_deg8'                    => '152',
        'prn04'                      => '18',
        'ddmmyy'                     => '181114',
        'date'                       => '18-11-2014',
        'num_sat_tracked'            => '7',
        'alt_meters'                 => '182.9',
        'az_deg4'                    => '278',
        'elev_deg6'                  => '22',
        'sig_str4'                   => '35',
        'vdop'                       => '1.97',
        'sig_str5'                   => '34',
        'tz_hours'                   => undef,
        'prn11'                      => '30',
        'lat_NS'                     => 'N',
        'pdop'                       => '2.30',
        'speed_over_ground'          => '0.03',
        'prn07'                      => '05',
        'prn12'                      => undef,
        'auto_man_D'                 => 'A',
        'sig_str1'                   => '27',
        'alt_meters_units'           => 'M',
        'data_valid'                 => 'A',
        'sig_str10'                  => '',
        'prn05a'                     => '29',
        'elev_deg8'                  => '14',
        'true_course'                => '121.37',
        'sig_str8'                   => '27',
        'elev_deg7'                  => '18',
        'prn12a'                     => '',
    );

    is_deeply( $nm->{DATA}, \%expected, "Parsing test" );
}
