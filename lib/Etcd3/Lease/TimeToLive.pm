use utf8;
package Etcd3::Lease::TimeToLive;

use strict;
use warnings;

use Moo;
use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use MIME::Base64;
use JSON;

with 'Etcd3::Role::Actions';

use namespace::clean;

=head1 NAME

Etcd3::Lease::TimeToLive

=cut

our $VERSION = '0.004';

=head1 DESCRIPTION

LeaseTimeToLive retrieves lease information.

=head2 endpoint

/lease/timetolive

=cut

has endpoint => (
    is      => 'ro',
    isa     => Str,
    default => '/lease/timetolive'
);

=head2 ID

ID is the requested ID for the lease. If ID is set to 0, the lessor chooses an ID.

=cut

has ID => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce   => sub { return encode_base64( $_[0], '' ) }
);

=head2 keys

keys is true to query all the keys attached to this lease.

=cut

has keys => (
    is       => 'ro',
    isa      => Bool
);

=head2 json_args

arguments that will be sent to the api

=cut

has json_args => ( is => 'lazy', );

sub _build_json_args {
    my ($self) = @_;
    my $args;
    for my $key ( keys %{$self} ) {
        unless ( $key =~ /(?:_client|json_args|endpoint)$/ ) {
            $args->{$key} = $self->{$key};
        }
    }
    return to_json($args);
}

=head2 init

=cut

sub init {
    my ($self) = @_;
    $self->json_args;
    return $self;
}

1;
