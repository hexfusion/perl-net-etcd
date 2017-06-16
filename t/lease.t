#!perl

use strict;
use warnings;

use Net::Etcd;
use Test::More;
use Test::Exception;
use Math::Int64 qw(int64_rand int64_to_string);
use Data::Dumper;

my ($host, $port);

if ( $ENV{ETCD_TEST_HOST} and $ENV{ETCD_TEST_PORT}) {
    $host = $ENV{ETCD_TEST_HOST};
    $port = $ENV{ETCD_TEST_PORT};
    plan tests => 14;
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_HOST and ETCD_TEST_PORT.";
}

my $etcd = Net::Etcd->new( { host => $host, port => $port } );

my $lease;
my $int64 = int64_rand();
my $lease_id = int64_to_string($int64);

# add lease
lives_ok(
    sub {
        $lease =
          $etcd->lease( { ID => $lease_id, TTL => 20 } )->grant;
    },
    "add a new lease"
);

cmp_ok( $lease->{response}{success}, '==', 1, "add lease success" );

# add lease to key
lives_ok( sub {  $lease = $etcd->put( { key => 'foo2', value => 'bar2', lease => $lease_id } ) },
    "add a new lease to a key" );

cmp_ok( $lease->{response}{success}, '==', 1, "add lease to key success" );

my $key;

# validate key
lives_ok( sub { $key = $etcd->range( { key => 'foo2' } )->get_value },
    "check value for key" );

cmp_ok( $key, 'eq', 'bar2', "lease key value" );

# lease keep alive
lives_ok( sub {  $lease = $etcd->lease( { ID => $lease_id } )->keepalive },
    "lease_keep_alive" );

cmp_ok( $lease->{response}{success}, '==', 1, "reset lease keep alive success" );

# lease ttl
lives_ok( sub {  $lease = $etcd->lease( { ID => $lease_id, keys => 1 } )->ttl },
    "lease_ttl" );

cmp_ok( $lease->{response}{success}, '==', 1, "return lease_ttl success" );

#print STDERR Dumper($lease);

# revoke lease
lives_ok( sub {  $lease = $etcd->lease( { ID => $lease_id } )->revoke },
    "revoke lease" );

#print STDERR Dumper($lease);

cmp_ok( $lease->{response}{success}, '==', 1, "revoke lease success" );

# validate key
lives_ok( sub { $key = $etcd->range( { key => 'foo2' } )->get_value },
    "check value for revoked lease key" );

is( $key, undef, "lease key revoked" );

1;

