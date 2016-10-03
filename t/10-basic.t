#!perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Etcd3;
use Etcd3::Config;
use Data::Dumper;

my $exec = Etcd3::Config->configuration->etcd;

print STDERR Dumper($exec);

unless (($exec && -x $exec)) {
    plan skip_all => "etcd not available.";
}

my %args;
my $etcd;

throws_ok { $etcd = Etcd3->connect() } qr/id/, "fail new with undef id";


