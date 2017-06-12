#!perl

use strict;
use warnings;
use Net::Etcd;
use Test::More;
use Test::Exception;
use Data::Dumper;
my ($host, $port);

if ( $ENV{ETCD_TEST_HOST} and $ENV{ETCD_TEST_PORT}) {
    $host = $ENV{ETCD_TEST_HOST};
    $port = $ENV{ETCD_TEST_PORT};
    plan tests => 5;
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_HOST and ETCD_TEST_PORT.";
}

my ($put, @op, @compare, $txn);
my $etcd = Net::Etcd->new( { host => $host, port => $port } );

lives_ok(
    sub {
        $put = $etcd->put( { key => 'foo', value => 'bar', hold => 1 } );
    },
    "put hold create"
);

#print STDERR Dumper($put);


lives_ok(
    sub {
        push @op, $etcd->op( { request_put => $put } );
    },
    "op request_put create"
);

#print STDERR Dumper(\@op);

lives_ok(
    sub {
        push @compare, $etcd->compare( { key => 'foo', target => 'CREATE', create_revision => '0' });
    },
    "compare create"
);

#print STDERR Dumper(\@compare);

lives_ok(
    sub {
        $txn = $etcd->txn( { compare => \@compare, success => \@op } );
    },
    "compare create"
);

cmp_ok( $txn->{response}{success}, '==', 1, "txn create success" );

print STDERR Dumper($txn);

1;
