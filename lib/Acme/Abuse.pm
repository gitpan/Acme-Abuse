package Acme::Abuse;

# Aplogies for the poor taste in sub names

use 5.006001;
use strict;
use warnings;

our $VERSION = '0.02';

use subs qw/import commit rpc suffer relieve AUTOLOAD/;

use Filter::Simple;
use Carp;
use Fcntl qw/F_SETFD/;
use Storable qw/store_fd fd_retrieve/;
use Data::Dumper;

our $Debug;

FILTER_ONLY code => sub {
    my $mod = qr|(?: \w+ :: )* \w+|x;

    s/ (?: ^ | (?<=[;}]) ) (\s*) abuse (\s+) ($mod) (.*?) ;/
    qq[$1 BEGIN { Acme::Abuse::commit $2 "$3"] . (($4 =~ m|\S|) ? ", $4 }" : " }")/gex;
},
    all => sub { $Debug and print };

my %Mods;

my $ARGV_Mgc = "Was4fusTwRaw4oeSfRo1boSh";
my $RPC_Mgc  = "1BartMEo Zac9tofF drAw0bYe";
my $Exp_Mgc  = "PeBahiN1 9TamphiA yaGi8Gib";

sub import {
    shift;
    my %args;
    @args{@_} = (1) x @_;

    $args{DEBUG} and $Debug = 1;

    $args{VICTIM} or return 1;

    {
        no warnings 'uninitialized';
        $ARGV[0] eq __PACKAGE__
            and $ARGV[1] eq $ARGV_Mgc
            and $ENV{PERL_ACME_ABUSE} =~ /$ARGV[2];/
            and suffer;
    }

    $args{FLYWEIGHT} and $Mods{caller()}{FLYWEIGHT} = 1;
}

sub commit {
    my $file = my $mod = shift;

    {
        no warnings 'uninitialized';
        $ENV{PERL_ACME_ABUSE} .= "$mod;";
    }

    $file =~ s|::|/|g;
    $file .= ".pm";
    for (@INC) {
        $file = "$_/$file", last if -f "$_/$file";
    }
    -f $file or croak "Can't find $mod in \@INC";
    $Mods{$mod}{FILE} = $file;

    pipe $Mods{$mod}{READ}, my $write or die "can't make pipe: $!";
    pipe my $read, $Mods{$mod}{WRITE} or die "can't make pipe: $!";

    for ($read, $write, @{$Mods{$mod}}{qw/READ WRITE/}) {
        select((select($_), $| = 1)[0]);
    }

    fcntl $write, F_SETFD, 0; # close-on-exec off
    fcntl $read,  F_SETFD, 0;

    defined(my $kid = fork) or die "can't fork: $!";

    unless($kid) {
        exec $file, __PACKAGE__, $ARGV_Mgc, $mod, fileno $read, fileno $write
            or croak "exec of $file failed: $!";
    }
    close $read;
    close $write;

    $Mods{$mod}{PID} = $kid;

    my $imports = eval { rpc $mod, scalar @_, @_, @ARGV }
                               or relieve $mod, "$mod ain't behavin': $@";
    "ARRAY" eq ref $imports    or relieve $mod, "$mod ain't behaving: " . ref $imports;
    $Exp_Mgc eq shift @$imports or relieve $mod, "$mod isn't behaving";
    
    my $into = caller;
    {
        no strict 'refs';
        *{"${into}::$_"} = \&{"${mod}::$_"} for @$imports;
        *{"${mod}::AUTOLOAD"} = \&Acme::Abuse::AUTOLOAD;
    }

}

sub relieve {
    my $mod = shift;
    return if $Mods{$mod}{VICTIM};
    $Debug and warn "relieving $mod";
    kill TERM => $Mods{$mod}{PID};
    close $Mods{$mod}{READ};
    close $Mods{$mod}{WRITE};
    delete $Mods{$mod};
    my $msg = shift;
    $msg and croak $msg;
}

sub rpc {
    my $to = shift;
    my $fn = shift;
    my $cx = wantarray;
    my @args = @_;
    
    if($to eq 'Acme::Abuse::Obj') {
        $to = $_[0]->{CLASS};
    }

    my $rpc = { SUB  => $fn,
                CX   => $cx,
                ARGS => \@args,
                MGC  => $RPC_Mgc
              };
               
    $Debug and warn "rpc $to " . fileno $Mods{$to}{WRITE};
    store_fd $rpc, $Mods{$to}{WRITE} or die "can't store: $!";
    $Debug and warn "sent";

    my $rv = fd_retrieve $Mods{$to}{READ};
    $Debug and warn "got rv";
    if('Acme::Abuse::Undef' eq ref) {
        croak "Undefined subroutine \&${to}::$fn called"
            unless $fn eq 'DESTROY';
    }
    return wantarray ? @$rv : $$rv;
}

sub suffer {
    $SIG{TERM} = sub {
        exit 0;
    };
    $SIG{INT} = sub {
        $Debug and Carp::confess;
    };

    my (undef, undef, $mod, $rfh, $wfh) = @ARGV;

    $mod eq caller(1) or croak "Someone's being too clever: $mod neq " . caller(1);

    ($rfh =~ /^(\d+)$/ and $rfh = $1) or die "You smell\n";
    ($wfh =~ /^(\d+)$/ and $wfh = $1) or die "I don't want to play with you\n";
    ($mod =~ /^([\w:]+)$/ and $mod = $1) or die "I hate you\n";
    
    $Mods{$mod}{VICTIM} = 1;

    open my $READ,  "<&=$rfh" or die "can't open read fd: $!";
    open my $WRITE, ">&=$wfh" or die "can't open write fd: $!";

    select((select($READ), $|=1)[0]);
    select((select($WRITE),$|=1)[0]);

    $Debug and warn "started initial rpc from " . fileno $READ;

    my $rpc = eval { fd_retrieve $READ } or die "I don't like you: $@\n";
    ref($rpc) eq "HASH" and $rpc->{MGC} eq $RPC_Mgc 
      or die "I'm not interested in you\n";

    @ARGV = @{$rpc->{ARGS}};
    my @imports = splice @ARGV, 0, $rpc->{SUB}, ();

    {
        package Acme::Abuse::Dummy;
        (my $file = $mod) =~ s|::|/|g;
        require "$file.pm";
        import $mod @imports;
    }
    my @exports = ($Exp_Mgc);
    {
        no strict 'refs';
        for (keys %{"Acme::Abuse::Dummy::"}) {
            if(exists &{"Acme::Abuse::Dummy::$_"}) {
                push @exports, $_;
            }
        }
    }
    my $exports = \@exports; # because we need to be called in scalar context
    store_fd \$exports, $WRITE;
    
    my %Objs;

    while (1) {
        no strict 'refs';

        $rpc = eval { fd_retrieve $READ } or die "I don't like you: $@\n";
        ref($rpc) eq "HASH" and $rpc->{MGC} eq $RPC_Mgc 
          or die "I'm not interested in you\n";

        my $sub  = $rpc->{SUB};
        my @args = @{$rpc->{ARGS}};
        my $cx   = $rpc->{CX};

        if($Mods{$mod}{FLYWEIGHT}) {
            for(@args) {
                if(UNIVERSAL::isa $_, "Acme::Abuse::Obj") {
                    $_ = $Objs{$_->{OBJ}};
                }
            }
        }
        
        unless(exists &{"${mod}::$sub"}) {
            my $undef;
            my $rv = \$undef;
            bless $rv, "Acme::Abuse::Undef";
            store_fd $rv, $WRITE;
        }

        my ($rv, @rv);
        if($cx) {
            @rv = &{"${mod}::$sub"}(@args);
            if($Mods{$mod}{FLYWEIGHT}) {
                for (@rv) {
                    if(UNIVERSAL::isa $_, $mod) {
                        $Objs{$_} = $_;
                        $_ = bless { OBJ => "$_", CLASS => $mod }, "Acme::Abuse::Obj";
                    }
                }
            }
        } elsif(defined $cx) {
            $rv = &{"${mod}::$sub"}(@args);
            if($Mods{$mod}{FLYWEIGHT}) {
                if(UNIVERSAL::isa $rv, $mod) {
                    $Objs{$rv} = $rv;
                    $rv = bless { OBJ => "$rv", CLASS => $mod }, "Acme::Abuse::Obj";
                }
            }
        } else {
            &{"${mod}::$sub"}(@args);
        }

        store_fd $cx ? \@rv : \$rv, $WRITE;
    }
}

our $AUTOLOAD;

sub AUTOLOAD {
    my ($mod, $sub) = ($AUTOLOAD =~ /(.*)::(.*)/);
    unshift @_, $sub;
    unshift @_, $mod;
    goto &rpc;
}

*Acme::Abuse::Obj::AUTOLOAD = \&AUTOLOAD;
*Acme::Abuse::Obj::AUTOLOAD = \&AUTOLOAD; # for -w

END {
    relieve $_ for keys %Mods;
}

1;
__END__

=head1 NAME

Acme::Abuse - Perl extension for setid modules

=head1 SYNOPSIS

WARNING! WARNING! WARNING!

  This module B<HAS NOT> been security audited by anyone competent to
  do so. If you use it, you assume all responsibility for ensuring it
  meets your security requirements.

WARNING! WARNING! WARNING!

  use Acme::Abuse;
  abuse Abused;

# Abused.pm (should be executable and setid)

  #!/usr/bin/perl
  
  use strict;
  use warnings;

  use Acme::Abuse VICTIM => 'FLYWEIGHT';

=head1 DESCRIPTION

This module arose out of a comment on clpmisc that it would be useful
to have a way of 'abusing' a module which would invoke a new setid
perl interpreter and pass all calls to the given module to that.

C<use Acme::Abuse> installs a code filter which causes C<abuse Abused>
to load Abused.pm setid, if it is compatible, and arrange for all
calls to functions in Abused:: to be passed to this setid perl.

Modules which wish to be abused must declare this with C<use
Acme::Abuse 'VICTIM'>. They should also have a #! line, and be
executable and appropriately setid. The C<use Acme::Abuse> line should
come right after the #! line, an appropriate C<package> statement,
possibly C<use strict; use warnings;> and any <use lib> needed to find
Acme::Abuse.

The abused module file will actually C<exec>d, and passed a pair of
pipes to communicate with the parent process through. When a sub in
the abused package is invoked, the sub's name, arguments and context
are frozen with L<Storable|Storable> and passed to the child. The
child then invokes the appropriate sub, freezes the results and passes
them back. 

This means that anything which cannot be successfully frozen, such a
filehandles, cannot be passed or returned. Closures can be used iff
both processes set $Storable::Eval to true: note that this is probably
hideously insecure. As a partial workaround for this, OO modules can
pass 'FLYWEIGHT' on their C<use Acme::Abuse> line: this will cause all
all objects derived from your class to only exist in the setid
interpreter. Acme::Abuse::Obj objects will be passed back instead, and
these will be translated back into the real objects when they are used
as sub arguments.

=head1 BUGS

I assume that the abused module defines exactly one package, and also
that the C<import> method does nothing cleverer than importing some
subs into the caller's namespace. Anything more than this will break.

The setid process is a completely separate interpreter, so any modules
or pragmas used in the parent process will not affect it.

This module is almost certainly not portable away from Unix; although
the pass-frozen-stuff-through-pipes idea is pretty general, so if you
can find a way to make your module file executable as a perl program
with enhanced priviledges you may be able to use it.

The test suite is pitifully incomplete.

There are almost certainly serious bugs lurking somewhere in code this funky :).

=head1 SEE ALSO

L<perlfunc/use>, L<Filter::Simple|Filter::Simple>, L<Storable|Storable>

=head1 AUTHOR

Ben Morrow E<lt>Acme-Abuse@morrow.me.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003 by Ben Morrow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
