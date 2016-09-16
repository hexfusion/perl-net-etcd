package Etcd3::Range;

use strict;
use warnings;

use Moo;
use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use MIME::Base64;
use JSON;

use namespace::clean;

#with 'Etcd3::Role::Request';

=head1 NAME

Etcd3::Range

=head2 endpoint

=cut

has endpoint => (
    is       => 'ro',
    isa      => Str,
    default => '/kv/range'
);

=head2 key

=cut

has key => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce => sub { return encode_base64($_[0],'') }
);

=head2 range_end

=cut

has range_end => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce => sub { return encode_base64($_[0],'') }
);

=head2 limit

=cut

has limit => (
    is       => 'ro',
    isa      => Str,
);

=head2 sort_order

=cut

has sort_order => (
    is       => 'ro',
    isa      => Str,
);

=head2 sort_target

=cut

has sort_target => (
    is       => 'ro',
    isa      => Str,
);

=head2 serializable

0/1 = true/false

=cut

has serializable => (
    is       => 'ro',
    isa      => Bool,
    coerce => sub { no strict 'refs'; return $_[0] ? JSON::true : JSON::false }
);

=head2 json_args

must be true or false

=cut

has json_args => (
    is => 'lazy',
);

sub _build_json_args {
    my ($self) = @_;
    my $args;
    for my $key ( keys %{ $self }) {
        unless ( $key =~  /(?:args|endpoint)$/ ) {
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
