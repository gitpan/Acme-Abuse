use 5.006001;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Acme::Abuse',
    VERSION_FROM      => 'lib/Acme/Abuse.pm',
    PREREQ_PM         => { 
        Storable         => 0,
        'Filter::Simple' => 0
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Acme/Abuse.pm',
       AUTHOR         => 'Ben Morrow <Acme-Abuse@morrow.me.uk>') : ()),
);
