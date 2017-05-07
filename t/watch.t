#!perl

use strict;
use warnings;
use AnyEvent;
use Etcd3;
use JSON;
use Test::More;
use Test::Exception;
use Data::Dumper;
my ($host, $port);

if ( $ENV{ETCD_TEST_HOST} and $ENV{ETCD_TEST_PORT}) {
    $host = $ENV{ETCD_TEST_HOST};
    $port = $ENV{ETCD_TEST_PORT};
    plan tests => 7;
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_HOST and ETCD_TEST_PORT.";
}

my ($watch,$key);
my $etcd = Etcd3->connect( $host, { port => $port } );
my $cv = AnyEvent->condvar;

our @events;
# create watch with callback and store events
lives_ok(
    sub {
        $watch = $etcd->watch( { key => 'foo'}, sub {
            my (undef, $result) =  @_;
            push @events, $result;
            #print STDERR Dumper(undef, $result);
        })->create;
    },
    "watch create"
);

lives_ok(
    sub {
        $key = $etcd->kv( { key => 'foo', value => 'bar' } )->put;
    },
    "kv put"
);

#print STDERR Dumper($key);
cmp_ok( $key->{response}{success}, '==', 1, "kv put success" );

# get range
lives_ok(
    sub {
        $key = $etcd->kv( { key => 'foo' } )->range
    },
    "kv range"
);

cmp_ok( $key->{response}{success}, '==', 1, "kv range success" );
#print STDERR Dumper($key);

# delete range
lives_ok(
    sub {
        $key = $etcd->kv( { key => 'foo' } )->range_delete
    },
    "kv range_delete"
);

#print STDERR Dumper($key);
cmp_ok( $key->{response}{success}, '==', 1, "kv delete success" );

cmp_ok( scalar @events, '==', 3, "number of async events stored. (create_watch, create key, delete key)" );
#print STDERR 'events ' . Dumper(@events);

undef $cv;

1;
