#!perl

use strict;
use warnings;

use Etcd3;
use Test::More;
use Test::Exception;
use Data::Dumper;

my ($host, $port);

if ( $ENV{ETCD_TEST_HOST} and $ENV{ETCD_TEST_PORT}) {
    $host = $ENV{ETCD_TEST_HOST};
    $port = $ENV{ETCD_TEST_PORT};
    plan tests => 2;
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_HOST and ETCD_TEST_PORT.";
}

my $etcd = Etcd3->connect( $host, { port => $port } );

my $lease;

# add lease
lives_ok(
    sub {
        $lease =
          $etcd->lease_grant( { ID => 7587821338341002662, TTL => 20 } )->request;
    },
    "add a new lease"
);

#print STDERR Dumper($lease);

# delete user
lives_ok( sub {  $lease = $etcd->put( { key => 'foo1', value => 'bar', lease => 7587821338341002662 } )->request },
    "add a new lease to a put" );

#print STDERR Dumper($lease);

1;
