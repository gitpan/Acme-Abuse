#!/usr/bin/perl

package Acme::Abuse::Test;

use strict;
use warnings;

use lib "t";

use Acme::Abuse VICTIM => 'FLYWEIGHT';

use base qw/Exporter/;

our @EXPORT;
BEGIN { @EXPORT = qw/scal list cx object method/ }
use subs @EXPORT;

sub scal {
    return $>;
}

sub list {
    my $arg = shift;
    return ($arg, $<, $>);
}

sub cx {
    return wantarray ? ("LIST") : "SCALAR";
}

sub object {
    my $self = sub { return @_ };
    return bless $self, shift;
}

sub method {
    my $s = shift;
    return $s->(@_);
}

1;
