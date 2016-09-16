package Etcd3;
# ABSTRACT: Provide access to the etcd v3 API.

use strict;
use warnings;

use Moo;
use JSON;
use HTTP::Tiny;
use MIME::Base64;
use Type::Tiny;
use Etcd3::Config;
use Etcd3::Types qw(:all);
use Etcd3::Range;
use Etcd3::Put;
use MooX::Aliases;
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

=head1 SYNOPSIS

    Etcd3->new({ host => 'my-etcd.com', port => 4001, user => 'etcd-user' pass => 'P@$$' });

    # put key
    $etcd->put({ key =>'foo1', value => 'bar' });

    # get single key
    $etcd->range({ key =>'test0' });

    # get range of keys
    $etcd->range({ key =>'test0', range_end => 'test100' });

=head1 DESCRIPTION

Perl access to Etcd v3 API.

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
   return { 'Authorization' => 'Basic ' . $self->auth } if ($self->user and $self->pass);
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
#    isa   => HashRef
);

sub _build_headers {
    my ($self) = @_;
    my @headers;
    push @headers, $self->auth if $self->auth;
    @headers or return;
    return \@headers;
}

=head2 range

returns a Etcd3::Range object via Type magic.

$etcd->range({ key =>'test0', range_end => 'test100', serializable => 1 })

=cut

has range => (
   is => 'rw',
   alias => 'get',
   isa => Range,
   coerce => RangeRequest,
);

=head2 get

alias for range to reduce confusion v2 -> v3. This may go away in future versions.

=cut

=head2 put

returns a Etcd3::Put object via Type magic.

=cut

has put => (
   is => 'rw',
   isa => Put,
   coerce => PutRequest,
);

=head2 api_root

=cut

has api_root => (
    is => 'lazy'
);

sub _build_api_root {
    my ($self) = @_;
    return ($self->ssl ? 'https' : 'http') .'://'.$self->host.':'.$self->port;
}

=head2 api_path

=cut

has api_path => (
    is => 'lazy'
);

sub _build_api_path {
    my ($self) = @_;
    return $self->api_root . $self->api_prefix;
}


=head2 actions

outputa aoh defining action class results

=cut

has actions => (
   is => 'lazy'
);

sub _build_actions {
    my ($self) = @_;
    my @methods =  qw(put range);
    my @actions = map { if ($self->{$_}) {
         {
             endpoint => $self->{$_}{endpoint},
             json_args => $self->{$_}{json_args}
         }
    } else {()} } @methods;
    return \@actions;
}

=head2 request

=cut

has request => (
    is => 'lazy',
#    isa => class_type('HTTP::Tiny')
);

sub _build_request {
   my ($self) = @_;
   my @response;
   for my $action (@{$self->actions}) {
      my $request = "HTTP::Tiny"->new->post(
         $self->api_path . $action->{endpoint} => {
           content => $action->{json_args},
             headers => {
               "Content-Type" => "application/json",
             #   $self->headers
             },       
         },
      );
      push @response, $request
   }
   return \@response;
}

=head2 value

returns single decoded value or the first.

=cut

sub value {
    my ($self) = @_;
    my $response = $self->request;
    my $content = from_json($response->[0]{content});
    my $value = $content->{kvs}[0]->{value};
    return decode_base64($value);
}

=head2 configuration

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

