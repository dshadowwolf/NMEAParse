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

sub get_position {
    my $self = shift;
    my $d    = $self->{DATA};

    return ( $d->{lat_NS}, $d->{latitude}, $d->{lon_EW}, $d->{longitude} );
}

sub get_time {
    my $self = shift;
    my $d    = $self->{DATA};

    return $d->{time_utc};
}

sub get_heading {
    my $self = shift;
    my $d    = $self->{DATA};

    return $d->{course_true};
}

sub get_speed {
    my $self = shift;
    my $d    = $self->{DATA};

    return $d->{speed_in_kph};
}

1;
