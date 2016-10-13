#!perl

use strict;
use warnings;

use Etcd3;
use Test::More;
use Test::Exception tests => 6;

my $host;

if ( $ENV{ETCD_TEST_HOST} ) {
    $host = $ENV{ETCD_TEST_HOST};
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_HOST.";
}

my $port;

if ( $ENV{ETCD_TEST_PORT} ) {
    $port = $ENV{ETCD_TEST_PORT};
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_PORT.";
}

my $etcd = Etcd3->connect( $host, { port => $port } );

my $user;

# add user
lives_ok(
    sub {
        $user =
          $etcd->user_add( { name => 'samba', password => 'foo' } )->request;
    },
    "add a new user"
);

# delete user
lives_ok( sub { $user = $etcd->role_add( { name => 'myrole' } )->request },
    "add a new role" );

# grant role
lives_ok(
    sub {
        $user =
          $etcd->grant_role( { user => 'samba', role => 'myrole' } )->request;
    },
    "add role to user"
);

# revoke role
lives_ok(
    sub {
        $user =
          $etcd->revoke_role( { name => 'samba', role => 'myrole' } )->request;
    },
    "remove role from user"
);

# delete role
lives_ok( sub { $user = $etcd->role_delete( { role => 'myrole' } )->request },
    "delete role" );

# delete user
lives_ok( sub { $user = $etcd->user_delete( { name => 'samba' } )->request },
    "deleted user" );

1;
