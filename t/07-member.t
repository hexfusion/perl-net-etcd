#!perl

use strict;
use warnings;
use Net::Etcd;
use Test::More;
use Test::Exception;
use Data::Dumper;
use Cwd;

my $config;
my $dir = getcwd;

if ( $ENV{ETCD_TEST_HOST} and $ENV{ETCD_TEST_PORT} ) {
    $config->{host}      = $ENV{ETCD_TEST_HOST};
    $config->{port}      = $ENV{ETCD_TEST_PORT};
    $config->{ca_file}   = $ENV{ETCD_CA_FILE} || "$dir/t/tls/ca.pem";
    $config->{key_file}  = $ENV{ETCD_KEY_FILE} || "$dir/t/tls/client-key.pem";
    $config->{cert_file} = $ENV{ETCD_CERT_FILE} || "$dir/t/tls/client.pem";
    $config->{ssl}       = 1;
    plan tests => 4;
}
else {
    plan skip_all =>
      "Please set environment variable ETCD_TEST_HOST and ETCD_TEST_PORT.";
}

my $member;
my $etcd = Net::Etcd->new($config);

my $new_peer = ( ['http://10.0.1.11:2380'] );

# member list
lives_ok(
    sub {
        $member = $etcd->member()->list;
    },
    "member list"
);

print STDERR Dumper($member);
cmp_ok( $member->is_success, '==', 1, "member list success" );

# member add
lives_ok(
    sub {
        $member = $etcd->member( { peerURLs => $new_peer } )->add;
    },
    "member add"
);

print STDERR Dumper($member);
cmp_ok( $member->is_success, '==', 1, "member add success" );

1;
