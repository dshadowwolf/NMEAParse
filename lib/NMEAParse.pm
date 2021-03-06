#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse;

our $VERSION = '0.0.3';

use List::Util qw/reduce first/;
use Carp qw/carp croak/;
use Module::Loader;
use Class::Method::Modifiers qw/fresh/;
use Readonly;

sub new {
    my ( $class, @wanted ) = @_;
    my $self = bless {}, $class;

    $self->{DATA} = {};
    my $loader  = Module::Loader->new();
    my @plugins = $loader->find_modules('NMEAParse');

    foreach my $pos (@wanted) {
        if ( $self->can($pos) ) {
            next;
        }

        my $plug = first {m/$pos/sxm} @plugins;
        if ( !$plug ) {
            carp "Unable to find handler for message type $pos";
        }

        $loader->load($plug);
        fresh $pos => sub { $plug->process(@_) };
    }

    return $self;
}

sub checksum {
    return sprintf '%02X', ord reduce { $a ^ $b } split //sxm, shift;
}

sub parse {
    Readonly my $CSUM_STARTS       => 3;
    Readonly my $CSUM_VALUE_STARTS => -2;
    Readonly my $END_OF_ARRAY      => -1;

    my $self = shift;
    my $data = shift;

    if ( !$data ) { croak 'no data!'; }
    chomp $data;
    $data =~ s/\r//xms
        ;    # chomp will kill the newline, but not the carriage return
    if ( !( $data =~ /^\$.*$/xmis ) ) { return; }
    my $break_sentence = $data;
    $break_sentence =~ s/\$(.*)[*][[:xdigit:]]{2}/$1/xms;
    my $expected_checksum = $data;
    $expected_checksum =~ s/\$.*[*]([[:xdigit:]]{2})/$1/xms;

    if ( checksum($break_sentence) ne $expected_checksum ) {
        croak "Invalid checksum - $expected_checksum != "
            . checksum($break_sentence);
    }

    my @fields           = split /,/xms, $break_sentence;
    my $type_with_talker = $fields[0];
    my $just_type        = do {
        my @yyy = split //xms, $type_with_talker;
        join q//, @yyy[ 0 - $CSUM_STARTS .. $END_OF_ARRAY ];
    };

    my $subr = $self->can($just_type);

    if ( !$subr ) {
        carp
            "Asked to parse message $just_type that I was not configured for.";
    }

    $self->$just_type( @fields[ 1 .. $#fields ] );
    if ( $self->{DATA}->{lat_ddmm} ) {
        if (   $self->{DATA}->{latitude}
            && $self->{DATA}->{latitude} != $self->{DATA}->{lat_ddmm} )
        {
            $self->{DATA}->{latitude} = $self->{DATA}->{lat_ddmm};
        }
        else {
            $self->{DATA}->{latitude} = $self->{DATA}->{lat_ddmm};
        }
    }
    if ( $self->{DATA}->{lon_ddmm} ) {
        if (   $self->{DATA}->{longitude}
            && $self->{DATA}->{longitude} != $self->{DATA}->{lon_ddmm} )
        {
            $self->{DATA}->{longitude} = $self->{DATA}->{lon_ddmm};
        }
        else {
            $self->{DATA}->{longitude} = $self->{DATA}->{lon_ddmm};
        }
    }
    return;
}

sub get_position {
    my $self = shift;
    my $d    = $self->{DATA};

    my $lns = q{};
    my $lat = q{};
    my $lew = q{};
    my $lon = q{};

    if ( defined $d->{lat_NS} )    { $lns = $d->{lat_NS}; }
    if ( defined $d->{latitude} )  { $lat = $d->{latitude}; }
    if ( defined $d->{lon_EW} )    { $lew = $d->{lon_EW}; }
    if ( defined $d->{longitude} ) { $lon = $d->{longitude}; }

    return ( $lns, $lat, $lew, $lon );
}

sub get_time {
    my $self = shift;
    my $d    = $self->{DATA};

    if   ( defined $d->{time_utc} ) { return $d->{time_utc}; }
    else                            { return q{}; }
}

sub get_heading {
    my $self = shift;
    my $d    = $self->{DATA};

    if   ( defined $d->{course_true} ) { return $d->{course_true}; }
    else                               { return q{}; }
}

sub get_speed {
    my $self = shift;
    my $d    = $self->{DATA};

    if   ( defined $d->{speed_in_kph} ) { return $d->{speed_in_kph}; }
    else                                { return q{}; }
}

1;

__END__

=head1 NAME

NMEAParse - Parse NMEA 0183 compliant sentences

=head1 SYNOPSIS

  use NMEAParse;
  my $parser = NMEAParse->new( ... );
  $parser->parse( ... );
  
=head1 DESCRIPTION

NMEAParse is an extensible parser for NMEA 0183 sentences. Each sentence
is represented by a sub-module named after the type field of the sentence
that can be loaded at parser creation by telling the parser that you expect that
sentence.

This module exists because GPS::NMEA expects to handle all IO internally and
in a blocking manner. Since there are situations where the IO is going to be
done elsewhere manually or where the programmer has decided to do the IO
asynchronously, this module was born.

The actual interpretation of the data is handled by plugin-like modules that are
in the NMEAParse namespace (or directory) somewhere in @INC and must
have function named 'process' available.

=head1 USAGE

Using the parser is as easy as creating the object and handing it data to parse:

C<use NMEAParse;>

C<my $parser = NMEAParse-E<gt>new( qw/GGA GLL GSA GSV RMC VTG ZDA/ );>

C<$parser-E<gt>parse( '$GPGGA,201548.000,3912.4397,N,08427.5741,W,2,7,1.18,182.9,M,-33.3,M,0000,0000*6A');>

Getting the data out is as simple - it's stored as a hash, so...

C<my %data = $parser-E<gt>{DATA};>

is all that is needed for access to the data that the parser has pulled from the
NMEA sentences it has processed.

=head2 METHODS

=over

=item NMEAParse->new( ... )

Creates a new NMEAParse object. The arguments are a list of the types of
NMEA sentences that the parser should be prepared to handle.

The current list of NMEA sentences the parser has handlers for are:
  GGA
  GLL
  GSA
  GSV
  RMC
  VTG
  ZDA

=back

=over

=item NMEAParse::checksum( $sentence_to_checksum )

This function is used internally to validate the checksum of an input NMEA
sentence. To use it, pass in the NMEA sentence without the leading sigil or
trailing checksum and it will return the value you can then check against the
device-supplied checksum or append to your own sentence.

=back

=over

=item NMEAParse::parse( $sentence_to_parse )

NMEAParse::parse is the interface to actually parsing the NMEA sentences. The
C<sentence_to_parse> argument is the complete NMEA 0183 sentence (trailing
carriage return and newline optional). This function does not return any value,
instead the parsed data is stored in an internal structure that you can later
deference.

=back

=over

=item NMEAParse::get_position

Returns the raw NMEA data of the current location. If this data is unavailable
it will be replaced with the empty string.

=back

=over

=item NMEAParse::get_time

Returns the current UTC time as parsed from the passed in NMEA data. If this
data is unavailable, it will return the empty string.

=back

=over

=item NMEAParse::get_heading

This function returns the current 'true' heading (as opposed to magnetic) that 
has been parsed from the NMEA data. Should this data be unavailable, the
empty string will be returned.

=back

=over

=item NMEAParse::get_speed

Get the current reported velocity of the GPS receiver, in kilometers per hour,
as parsed from the NMEA data. Should this be unavailable, an empty string
will be returned.

=back

=head1 DEPENDENCIES

For various reasons this code depends on the following modules:

=over

=item  *

List::Util

=item  *

Carp

=item  *

Module::Loader

=item  *

Class::Method::Modifiers

=item  *

Readonly

=back

=head1 INCOMPATIBILITIES

This module is not known to be incompatible with any other existing code.

=head1 BUGS AND LIMITATIONS

Due to the newness of this code, there are no known bugs. To report bugs or to provide a patch or failing test, please see the GitHub repository L<http://www.github.com/dshadowwolf/NMEAParse> for this code.

=head1 TODO

=over

=item Expand the number of known NMEA 0183 sentences

=item Expand the documentation to be much better

=back

=head1 AUTHOR
Daniel Hazelton <dshadowwolf@gmail.com>

some contributions from others

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014 Daniel Hazelton. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms as Perl
itself.

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=head1 DIAGNOSTICS

=head1 EXIT STATUS

=head1 CONFIGURATION

=cut
