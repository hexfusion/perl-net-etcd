use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Net::Etcd',
    AUTHOR       => q{Sam Batschelet (hexfusion) <sbatschelet@mac.com>},
    VERSION_FROM => 'lib/Net/Etcd.pm',
    ABSTRACT => 'Provide access to the etcd v3 API.',
    LICENSE  => 'perl',
    PL_FILES => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'File::Spec'            => 0,
        'File::Temp'            => 0,
        'Test::More'            => 0,
        'Test::Exception'       => 0,
    },
    PREREQ_PM => {
        'Moo'                   => '2.000',
        'namespace::clean'      => 0,
        'Sub::Quote'            => 0,
        'URI'                   => 0,
        'HTTP::Tiny'            => 0,
        'Types::Standard'       => 0,
        'AnyEvent'              => '7.14',
        'AnyEvent::HTTP'        => 0,
        'JSON'                  => 0,
        'Math::Int64'           => 0,
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    META_MERGE => {
        resources => {
            repository =>
              'https://github.com/hexfusion/perl-net-etcd.git',
            bugtracker =>
              'https://github.com/hexfusion/perl-net-etcd/issues',
        },
    },
);
