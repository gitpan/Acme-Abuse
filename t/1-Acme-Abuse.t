# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Acme-Abuse.t'

#########################

use warnings;
use strict;

use Test::More tests => 9;

BEGIN { use_ok('Acme::Abuse') };

use lib "t";

my $mod;

BEGIN {
    $mod = "t/Acme/Abuse/Test.pm";
    my @st = stat $mod                  or die "can't stat test module: $!";
    unless ($st[2] & 07777 == 04755) {
        my $id = (getpwnam "nobody")[2] or die "can't find nobody: $!";
        chown $id, -1, $mod             or die "can't chown test module: $!";
        chmod 04755, $mod               or die "can't chmod test module: $!";
    }
}

my @st = stat $mod or die "can't stat test module: $!";
my ($rid, $eid) = ($<, $st[4]);

abuse Acme::Abuse::Test;

ok exists &Acme::Abuse::Test::AUTOLOAD,     "create AUTOLOAD";
ok exists &scal,                            "import subs";

is scal, $eid,                              "scalar";
is_deeply [list { hello => 'world' }], 
  [{ hello => 'world' }, $rid, $eid],       "list";
is cx, "SCALAR",                            "scalar cx";
is_deeply [cx], ["LIST"],                   "list cx";

my $obj = Acme::Abuse::Test->object;
ok ref($obj) && UNIVERSAL::isa($obj, "Acme::Abuse::Obj"), "object";
is_deeply $obj->method({ hello => 'world' }),
{ hello => 'world' },                       "method";

my $warning;
$SIG{__WARN__} = sub {
    $warning = $_[0];
};
