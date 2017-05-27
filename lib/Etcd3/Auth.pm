use utf8;
package Etcd3::Auth;

use strict;
use warnings;

=encoding utf8

=cut

use Moo;
use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use Etcd3::Auth::Authenticate;
use Etcd3::Auth::Role;

with 'Etcd3::Role::Actions';

use namespace::clean;


=head1 NAME

Etcd3::Auth

=cut

our $VERSION = '0.006';

=head1 DESCRIPTION

Authentication

=cut

=head1 SYNOPSIS

    # enable auth
    $etcd->user_add

    # add user
    $etcd->user_add( { name => 'samba', password =>'P@$$' });

    # add role
    $etcd->role( { name => 'myrole' })->add;

    # grant role
    $etcd->user_role( { user => 'samba', role => 'myrole' })->grant;

=cut

=head2 endpoint

=cut

has endpoint => (
    is       => 'ro',
    isa      => Str,
);

=head1 PUBLIC METHODS

=head2 enable

Enable authentication, this requires the server to be settup with ssl

    $etcd->auth()->enable;

=cut

sub enable {
    my ( $self, $options ) = @_;
    $self->{endpoint} = '/auth/enable';
    $self->{json_args} = '{}';
    $self->request;
    return $self;
}

=head2 disable

disable authentication, this requires the server to be settup with ssl

    $etcd->auth()->disable;

=cut

sub disable {
    my ( $self, $options ) = @_;
    $self->{endpoint} = '/auth/disable';
    $self->{json_args} = '{}';
    $self->request;
    return $self;
}

1;
