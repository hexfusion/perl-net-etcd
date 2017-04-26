#!perl

use strict;
use warnings;

use Etcd3;
use Test::More;
use Test::Exception;


my ($host, $port);

if ( $ENV{ETCD_TEST_HOST} and $ENV{ETCD_TEST_PORT}) {
    $host = $ENV{ETCD_TEST_HOST};
    $port = $ENV{ETCD_TEST_PORT};
    plan tests => 12;
}
else {
    plan skip_all => "Please set environment variable ETCD_TEST_HOST and ETCD_TEST_PORT.";
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

 cmp_ok( $user->{success}, '==', 1, "add a new user success" );

# delete user
lives_ok( sub { $user = $etcd->role_add( { name => 'myrole' } )->request },
    "add a new role" );

cmp_ok( $user->{success}, '==', 1, "add a new role success" );

# grant role
lives_ok(
    sub {
        $user =
          $etcd->grant_role( { user => 'samba', role => 'myrole' } )->request;
    },
    "add role to user"
);

cmp_ok( $user->{success}, '==', 1, "add role to user success" );

# revoke role
lives_ok(
    sub {
        $user =
          $etcd->revoke_role( { name => 'samba', role => 'myrole' } )->request;
    },
    "remove role from user"
);

cmp_ok( $user->{success}, '==', 1, "remove role from user success" );

# delete role
lives_ok( sub { $user = $etcd->role_delete( { role => 'myrole' } )->request },
    "delete role" );

cmp_ok( $user->{success}, '==', 1, "delete role success" );

# delete user
lives_ok( sub { $user = $etcd->user_delete( { name => 'samba' } )->request },
    "deleted user" );

cmp_ok( $user->{success}, '==', 1, "deleted user success" );

1;
