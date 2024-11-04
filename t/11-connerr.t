#!perl

use strict;
use warnings;

use Net::Etcd;
use Test::More tests => 3;
use Test::Exception;
use Cwd;

my $config = {
    host => 'localhost',
    port => 123456,
};
my $dir = getcwd;
my $etcd = Net::Etcd->new($config);

my $range;

lives_ok(
    sub {
        $range = $etcd->range( { key => 'foo1' } );
    },
    "kv range"
);

my $response = $range->response;

cmp_ok( $response->{ success }, '==', 0, "Did not succeed" );
cmp_ok( $response->{ headers }{ Status }, '==', 595, "Connection error" );