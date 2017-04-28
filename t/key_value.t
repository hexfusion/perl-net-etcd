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
    plan tests => 6;
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_HOST and ETCD_TEST_PORT.";
}

my $etcd = Etcd3->connect( $host, { port => $port } );

my $key;

# put key/value
lives_ok(
    sub {
        $key = $etcd->kv( { key => 'foo1', value => 'bar' } )->put
    },
    "kv put"
);

cmp_ok( $key->{response}{success}, '==', 1, "kv put success" );

# get range
lives_ok(
    sub {
        $key = $etcd->kv( { key => 'foo1' } )->range
    },
    "kv range"
);

cmp_ok( $key->{response}{success}, '==', 1, "kv range success" );

#print STDERR Dumper($key);

# delete range
lives_ok(
    sub {
        $key = $etcd->kv( { key => 'foo1' } )->range_delete
    },
    "kv range_delete"
);

#print STDERR Dumper($key);

cmp_ok( $key->{response}{success}, '==', 1, "kv delete success" );

1;
