package Etcd3::Authenticate;

use strict;
use warnings;

use Moo;
use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use MIME::Base64;
use JSON;

use namespace::clean;

=head1 NAME

Etcd3:Authenticate

=head1 DESCRIPTION

Authentication request

=head2 endpoint

=cut

has endpoint => (
    is       => 'ro',
    isa      => Str,
    default => '/auth/authenticate'
);

=head2 user

=cut

has user => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce => sub { return encode_base64($_[0],'') }
);

=head2 password

=cut

has password => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce => sub { return encode_base64($_[0],'') }
);
=head2 json_args

arguments that will be sent to the api

=cut

has json_args => (
    is => 'lazy',
);

sub _build_json_args {
    my ($self) = @_;
    my $args;
    for my $key ( keys %{ $self }) {
        unless ( $key =~  /(?:json_args|endpoint)$/ ) {
            $args->{$key} = $self->{$key};
        }
    }
    return to_json($args);
}

sub request {
    my ($self)  = @_;
    $self->json_args;
    return $self;
}
1;
