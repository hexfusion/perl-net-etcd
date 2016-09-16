package Etcd3;
# ABSTRACT: Provide access to the etcd v3 API.

use strict;
use warnings;

use Moo;
use HTTP::Tiny;
use Type::Tiny;
use Etcd3::Config;
use Etcd3::Types qw(:all);
use Etcd3::Range;
use Etcd3::Put;
use Type::Utils qw(class_type);
use Types::Standard qw(Str Int Bool HashRef);
use MIME::Base64;

use namespace::clean;

=encoding utf8

=head1 NAME

Etcd3

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

=head2 host

=cut

has host => (
    is => 'ro',
    isa => Str,
    default => '127.0.0.1'
);

=head2 port

=cut

has port => (
    is => 'ro',
    isa => Int,
    default => '2379'
);

=head2 user

=cut

has user => (
    is => 'ro',
    isa => Str
);

=head2 password

=cut

has password => (
    is => 'ro',
    isa => Str
);

=head2 ssl

=cut

has ssl => (
    is => 'ro',
    isa => Bool,
);

=head2 auth

=cut

has auth => (
    is => 'lazy',
    isa => Bool,
);

sub _build_auth {
   my ($self) = @_;
   return 1 if ($self->user and $self->pass);
   return;
}

=head2 api_prefix

base enpoint for api call, refurs to api version.

=cut

has api_prefix => (
    is      => 'ro',
    isa     => Str,
    default => '/v3alpha'
);

=head2 headers

returns proper headers for api call.

=cut

has headers => (
    is    => 'lazy',
    isa   => HashRef
);

sub _build_headers {
    my $self   = @_;
    my @headers = $self->headers;
    push @headers, { 'Content-Type'  => 'application/json' };
    push @headers, { 'Authorization' => 'Basic ' . $self->auth } if $self->auth;
    @headers or return;
    return { headers => @headers };
}

=head2 range

returns a Etcd3::Range object via Type magic.

=cut

has range => (
   is => 'rw',
   isa => Range,
   coerce => RangeRequest,
);

=head2 put

returns a Etcd3::Put object via Type magic.

=cut

has put => (
   is => 'rw',
   isa => Put,
   coerce => PutRequest,
);

=head2 base_api

=cut

has base_api => (
    is => 'lazy'
);

sub _build_base_api {
    my ($self) = @_;
    ($self->ssl ? 'https' : 'http') .'://'.$self->host.':'.$self->port;
}

has request => (
    is => 'lazy',
    isa => class_type('HTTP::Tiny')
);

sub _build_http {
   my ($self) = @_;

#   my $response = "HTTP::Tiny"->new->post(
#       "http://api.metacpan.org/v0/release/_search" => {
#          content => to_json($query),
#          headers => {
#             "Content-Type" => "application/json",
#          },       },
#    );
#   my $request = "HTTP::Tiny"->new();
   return;# $request;
}

=head2

Initialize configuration checks to see it etcd is installed locally.

=cut


sub configuration {
    Etcd3::Config->configuration
}

sub BUILD {
    my ($self,$args) = @_;
    if (not -e $self->configuration->etcd) {
        my $msg = "No etcd executable found\n";
        $msg   .= ">> Please install etcd - https://coreos.com/etcd/docs/latest/";
        die $msg;
    }
}
1;

