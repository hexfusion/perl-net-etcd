#!/usr/bin/env perl

use strict;
use warnings;
use Net::Etcd;
use Data::Dumper;
my ($host, $port);

if ( $ENV{ETCD_TEST_HOST} and $ENV{ETCD_TEST_PORT}) {
    $host = $ENV{ETCD_TEST_HOST};
    $port = $ENV{ETCD_TEST_PORT};
}

my ($watch,$key);
my $etcd = Net::Etcd->new( { host => $host, port => $port } );

# create watch with callback and store events
$watch = $etcd->watch( { key => 'foo'}, sub {
	my ($result) =  @_;
    print STDERR Dumper($result);
})->create;

$etcd->put({ key => 'foo', value => 'bar' });

$etcd->range({ key => 'foo' });

1;
