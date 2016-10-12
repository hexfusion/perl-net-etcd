package Etcd3::Client;

use strict;
use warnings;

use Moo;
use JSON;
use HTTP::Tiny;
use MIME::Base64;
use Type::Tiny;
use Etcd3::Authenticate;
use Etcd3::Config;
use Etcd3::Range;
use Etcd3::DeleteRange;
use Etcd3::Put;
use Etcd3::Watch;
use Etcd3::AuthEnable;
use Type::Utils qw(class_type);
use Types::Standard qw(Str Int Bool HashRef);
use MIME::Base64;
use Data::Dumper;

use namespace::clean;

=encoding utf8

=head1 NAME

Etcd3::Client

=cut

=head1 DESCRIPTION

Client data for etcd connection

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

has name => (
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
   my $auth = Etcd3::AuthEnable->new(
    _client => $self,
    %$self
    );
   
   print STDERR Dumper($auth);
   return 1 if ($self->user and $self->password);
   return;
}

=head2 api_root

=cut

has api_root => (
    is => 'lazy'
);

sub _build_api_root {
    my ($self) = @_;
    return ($self->ssl ? 'https' : 'http') .'://'.$self->host.':'.$self->port;
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

has api_path => (
    is => 'lazy'
);

sub _build_api_path {
    my ($self) = @_;
    return $self->api_root . $self->api_prefix;
}

=head2 auth_token

=cut

has auth_token => (
    is => 'lazy'
);

sub _build_auth_token {
    my ($self) = @_;
   my $auth = Etcd3::AuthEnable->new(
    _client => $self,
    %$self
    )->init;

   print STDERR Dumper($auth->request);
    return Etcd3::Authenticate->new(
    _client => $self,
    %$self
    )->token;
}

=head2 headers

=cut

has headers => (
    is => 'lazy'
);

sub _build_headers {
    my ($self) = @_;
    my $headers;
    my $auth_token = $self->auth_token;
#    $headers->{'Content-Type'} = 'application/json';
#    $headers->{'Authorization'} = 'Bearer ' . encode_base64($auth_token,"") if $auth_token;
#    $headers->{'Grpc-Metadata-Authorization'} = encode_base64($auth_token,"");
    $headers->{'Grpc-Metadata-Foo'} = 'Bar';
    $headers->{'authorization'} =  $auth_token;
    return $headers;
}

=head2 watch

returns a Etcd3::Watch object.

$etcd->watch({ key =>'foo', range_end => 'fop' })

=cut

sub watch {
    my ( $self, $options ) = @_;
    return Etcd3::Watch->new(
        _client => $self,
        ( $options ? %$options : () ),
    )->init;
}

=head2 deleterange

returns a Etcd3::Range object via Type magic.

$etcd->deleterange({ key =>'test0', range_end => 'test100', prev_key => 1 })

=cut

sub deleterange {
    my ( $self, $options ) = @_;
    return Etcd3::DeleteRange->new(
        _client => $self,
        ( $options ? %$options : () ),
    )->init;
}

=head2 put

returns a Etcd3::Put object.

=cut

sub put {
    my ( $self, $options ) = @_;
    return Etcd3::Put->new(
        _client => $self,
        ( $options ? %$options : () ),
    )->init;
}

=head2 range

returns a Etcd3::Range object

$etcd->range({ key =>'test0', range_end => 'test100', serializable => 1 })

=cut

sub range {
    my ( $self, $options ) = @_;
    return Etcd3::Range->new(
        _client => $self,
        ( $options ? %$options : () ),
    )->init;
}

=head2 configuration

Initialize configuration checks to see it etcd is installed locally.

=cut

sub configuration {
    Etcd3::Config->configuration
}

sub BUILD {
    my ($self,$args) = @_;
    $self->headers;
    if (not -e $self->configuration->etcd) {
        my $msg = "No etcd executable found\n";
        $msg   .= ">> Please install etcd - https://coreos.com/etcd/docs/latest/";
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

Copyright 2016 Sam Batschelet (hexfusion).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


1;

