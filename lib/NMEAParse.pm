#!/usr/bin/perl

use strict;
use warnings;

package NMEAParse;

our $VERSION = '0.0.1';

use List::Util qw/reduce first/;
use Carp qw/carp croak/;
use Module::Loader;
use Class::Method::Modifiers qw/fresh/;
use Readonly;
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

=head2 Methods

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

=cut

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

=over

=item NMEAParse::checksum( $sentence_to_checksum )

This function is used internally to validate the checksum of an input NMEA
sentence. To use it, pass in the NMEA sentence without the leading sigil and
it will return the value you can then properly append to the NMEA sentence.

=back

=cut

sub checksum {
    return sprintf '%02X', ord reduce { $a ^ $b } split //sxm, shift;
}

=over

=item NMEAParse::parse( $sentence_to_parse )

NMEAParse::parse is the interface to actually parsing the NMEA sentences. The
C<sentence_to_parse> argument is the complete NMEA 0183 sentence (trailing
carriage return and newline optional). This function does not return any value,
instead the parsed data is stored in an internal structure that can be later
de-referenced.

=back

=cut

sub parse {
    Readonly my $CSUM_STARTS       => 3;
    Readonly my $CSUM_VALUE_STARTS => -2;
    Readonly my $END_OF_ARRAY      => -1;

    my $self = shift;
    my $data = shift;

    if ( !$data ) { croak 'no data!'; }
    chomp $data;
    if ( !( $data =~ /^\$.*$/xmis ) ) { return; }
    my $break_sentence = do {
        my @yyy = split //xms, $data;
        join q//, @yyy[ 1 .. $#yyy - $CSUM_STARTS ];
    };
    my $expected_checksum = do {
        my @yyy = split //xms, $data;
        join q//, @yyy[ $CSUM_VALUE_STARTS .. $END_OF_ARRAY ];
    };

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
    return;
}

=over

=item NMEAParse::get_position

Returns the raw NMEA data of the current location. If this data is unavailable
it will be replaced with the empty string.

=back

=cut

sub get_position {
    my $self = shift;
    my $d    = $self->{DATA};

    return ( $d->{lat_NS}, $d->{latitude}, $d->{lon_EW}, $d->{longitude} );
}

=over

=item NMEAParse::get_time

Returns the current UTC time as parsed from the passed in NMEA data. If this
data is unavailable, it will return the empty string.

=back

=cut

sub get_time {
    my $self = shift;
    my $d    = $self->{DATA};

    return $d->{time_utc};
}

=over

=item NMEAParse::get_heading

This function returns the current 'true' heading (as opposed to magnetic) that 
has been parsed from the NMEA data. Should this data be unavailable, the
empty string will be returned.

=back

=cut

sub get_heading {
    my $self = shift;
    my $d    = $self->{DATA};

    return $d->{course_true};
}

=over

=item NMEAParse::get_speed

Get the current reported velocity of the GPS reciever, in kilometers per hour,
as parsed from the NMEA data. Should this be unavailable, an empty string
will be returned.

=back

=cut

sub get_speed {
    my $self = shift;
    my $d    = $self->{DATA};

    return $d->{speed_in_kph};
}

=head1 BUGS

Due to the newness of this code, there are no known bugs. To report bugs or to provide a patch or failing test, please see the github repository for this code.

=head1 TODO

=over

=item Expand the number of known NMEA 0183 sentences

=item Expand the documentation to be much better


=back

=head1 AUTHORS
Daniel Hazelton <dshadowwolf@gmail.com>

some contributions from others

=head1 COPYRIGHT

Copyright (c) 2014 Daniel Hazelton. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

1;
