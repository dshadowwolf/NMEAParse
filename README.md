NMEAParse exists as a module because the parsing of the data should be
separate from the gathering of the same. The existing module for GPS interfacing
and parsing of NMEA data intermingles the two and it takes using an
undocumented function to simply parse the data instead of reading it from the
device and then parsing it.

As a design decision this module uses a plugin-like architecture where each
different sentence is handled by a sub-module that is passed the values of the
NMEA sentence as an array and the instance of the NMEAParse class and is
expected to inject the data with sensible names (perhaps derived from the NMEA
0183 specification) into the instances data-store.

Full documentation of the user-visible interface is available as POD in the
module source. Documentation of the nature of the plugins follows.

_Plugin_ _Architecture_

Each plugin is expected to be in the NMEAParse namespace (eg:
package NMEAParse::GGA) and named after the 3 character identifier of the
message. That means that a GPGLL (or GNGLL) message will be handled by a
plugin named GLL (NMEAParse::GLL). The plugin is required to have a function
available - named 'process' - that can be called to actually process the incoming
sentence data.

A hypothetical 'EXP' message would be in a file named 'EXP.pm' in a directory
in @INC named 'NMEAParse' and could easily be implemented as:

  #!perl

  use strict;
  use warnings;

  package NMEAParse::EXP;

  sub process {
    my ( $unused, $instance, @data ) = @_;
    my $d = $instance->{DATA};

    ( $d->{var1}, $d->{var2}, ) = @data;

    return;
  }

  1;

The preceding is, in fact, the basic skeleton of the existing plugins, save for
some differences in the naming of the variables.
