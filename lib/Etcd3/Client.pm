use utf8;
package Etcd3::Client;

use strict;
use warnings;

use Moo;
use JSON;
use HTTP::Tiny;
use MIME::Base64;
use Etcd3::Auth;
use Etcd3::Config;
use Etcd3::KV;
use Etcd3::Watch;
use Etcd3::Lease;
use Etcd3::User;
use Types::Standard qw(Str Int Bool HashRef);
use Data::Dumper;

use namespace::clean;

=encoding utf8

=head1 NAME

Etcd3::Client

=cut

our $VERSION = '0.005';

=head1 DESCRIPTION

Client data for etcd connection

=head2 host

=cut

has host => (
    is      => 'ro',
    isa     => Str,
    default => '127.0.0.1'
);

=head2 port

=cut

has port => (
    is      => 'ro',
    isa     => Int,
    default => '2379'
);

=head2 username

=cut

has username => (
    is  => 'ro',
    isa => Str
);

=head2 password

=cut

has password => (
    is  => 'ro',
    isa => Str
);

=head2 ssl

=cut

has ssl => (
    is  => 'ro',
    isa => Bool,
);

=head2 auth

=cut

has auth => (
    is  => 'lazy',
    isa => Bool,
);

sub _build_auth {
    my ($self) = @_;
    return 1 if ( $self->username and $self->password );
    return;
}

=head2 api_root

=cut

has api_root => ( is => 'lazy' );

sub _build_api_root {
    my ($self) = @_;
    return
        ( $self->ssl ? 'https' : 'http' ) . '://'
      . $self->host . ':'
      . $self->port;
}

=head2 api_prefix

base endpoint for api call, refers to api version.

=cut

has api_prefix => (
    is      => 'ro',
    isa     => Str,
    default => '/v3alpha'
);

=head2 api_path

=cut

has api_path => ( is => 'lazy' );

sub _build_api_path {
    my ($self) = @_;
    return $self->api_root . $self->api_prefix;
}

=head2 auth_token

=cut

has auth_token => ( is => 'lazy' );

sub _build_auth_token {
    my ($self) = @_;
    return Etcd3::Auth::Authenticate->new(
        _client => $self,
        %$self
    )->token;
}

=head2 headers

=cut

has headers => ( is => 'lazy' );

sub _build_headers {
    my ($self) = @_;
    my $headers;
    my $auth_token = $self->auth_token if $self->auth;
    $headers->{'Content-Type'} = 'application/json';
    $headers->{'authorization'} = 'Bearer ' . encode_base64( $auth_token, "" ) if $auth_token;
    return $headers;
}

=head1 PUBLIC METHODS

=head2 watch

returns a L<Etcd3::Watch> object.

$etcd->watch({ key =>'foo', range_end => 'fop' })

=cut

sub watch {
    my ( $self, $options ) = @_;
    my $cb = pop if ref $_[-1] eq 'CODE';
    return Etcd3::Watch->new(
        _client => $self,
        cb      => $cb,
        ( $options ? %$options : () ),
    );
}

=head2 role

$etcd->role({ role => 'foo' });

=cut

sub role {
    my ( $self, $options ) = @_;
    my $cb = pop if ref $_[-1] eq 'CODE';
    return Etcd3::Auth::Role->new(
        _client => $self,
        cb      => $cb,
        ( $options ? %$options : () ),
    );
}

=head2 user_role

$etcd->user_role({ name => 'samba', role => 'foo' });

=cut

sub user_role {
    my ( $self, $options ) = @_;
    my $cb = pop if ref $_[-1] eq 'CODE';
    return Etcd3::User::Role->new(
        _client => $self,
        cb      => $cb,
        ( $options ? %$options : () ),
    );
}

=head2 auth_enable

=cut

sub auth_enable {
    my ( $self, $options ) = @_;
    my $auth = Etcd3::Auth::Enable->new( _client => $self )->init;
    return $auth->request;
}


=head2 lease

L<Etcd3::Lease>

=cut

sub lease {
    my ( $self, $options ) = @_;
    my $cb = pop if ref $_[-1] eq 'CODE';
    return Etcd3::Lease->new(
        _client => $self,
        cb      => $cb,
        ( $options ? %$options : () ),
    );
}

=head2 user

L<Etcd3::User>

=cut

sub user {
    my ( $self, $options ) = @_;
    my $cb = pop if ref $_[-1] eq 'CODE';
    return Etcd3::User->new(
        _client => $self,
        cb      => $cb,
        ( $options ? %$options : () ),
    );
}

=head2 kv

L<Etcd3::KV>

=cut

sub kv {
    my ( $self, $options ) = @_;
    my $cb = pop if ref $_[-1] eq 'CODE';
    return Etcd3::KV->new(
        _client => $self,
        options => $options,
        cb      => $cb
    );
}

=head2 configuration

Initialize configuration checks to see it etcd is installed locally.

=cut

sub configuration {
    Etcd3::Config->configuration;
}

sub BUILD {
    my ( $self, $args ) = @_;
    $self->headers;
    if ( not -e $self->configuration->etcd ) {
        my $msg = "No etcd executable found\n";
        $msg .= ">> Please install etcd - https://coreos.com/etcd/docs/latest/";
        die $msg;
    }
}

=head1 AUTHOR

Sam Batschelet, <sbatschelet at mac.com>

=head1 ACKNOWLEDGEMENTS

The L<etcd> developers and community.

=head1 CAVEATS

The L<etcd> v3 API is in heavy development and can change at anytime please see
https://github.com/coreos/etcd/blob/master/Documentation/dev-guide/api_reference_v3.md
for latest details.


=head1 LICENSE AND COPYRIGHT

Copyright 2017 Sam Batschelet (hexfusion).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;

