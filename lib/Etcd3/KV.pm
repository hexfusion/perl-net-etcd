use utf8;
package Etcd3::KV;

use strict;
use warnings;

=encoding utf8

=cut
use Moo;
use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use Data::Dumper;
use Carp;
use Etcd3::KV::Put;
use Etcd3::KV::Range;

with 'Etcd3::Role::Actions';
use namespace::clean;

=head1 NAME

Etcd3::KV

=cut

our $VERSION = '0.005';

=head1 DESCRIPTION

Key Value

=cut

=head1 SYNOPSIS

=cut

=head2 options

=cut

has options => (
    is      => 'ro',
    isa     => HashRef,
);

=head2 range

Range gets the keys in the range from the key-value store.

    $etcd->kv({key =>'test0', range_end => 'test100'})->range

=cut

sub range {
    my ( $self ) = @_;
    my $options = $self->options;
    my $range = Etcd3::KV::Range->new(
        %$self,
        endpoint => '/kv/range',
        etcd => $self->etcd,
        ( $options ? %$options : () ),
    );
    $range->request;
    return $range;
}

=head2 range_delete

DeleteRange deletes the given range from the key-value store. A delete request increments the
revision of the key-value store and generates a delete event in the event history for every
deleted key.

    $etcd->kv({key =>'test0'})->range_delete

=cut

sub range_delete {
    my ( $self ) = @_;
    my $options = $self->options;
    my $range = Etcd3::KV::Range->new(
        %$self,
        endpoint => '/kv/deleterange',
        etcd => $self->etcd,
        ( $options ? %$options : () ),
    );
    $range->request;
    return $range;
}

=head2 put

Put puts the given key into the key-value store. A put request increments
the revision of the key-value store and generates one event in the event
history.

=cut

sub put {
    my ( $self ) = @_;
    my $options = $self->options;
    my $range = Etcd3::KV::Put->new(
        %$self,
        endpoint => '/kv/put',
        etcd => $self->etcd,
        ( $options ? %$options : () ),
    );
    $range->request;
    return $range;
}

1;
