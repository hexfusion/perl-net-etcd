use utf8;
package Net::Etcd::Auth;

use strict;
use warnings;

=encoding utf8

=cut

use Moo;
use JSON;
use Carp;
use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use Net::Etcd::Auth::Role;

with 'Net::Etcd::Role::Actions';

use namespace::clean;


=head1 NAME

Net::Etcd::Auth

=cut

our $VERSION = '0.011';

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

=head2 password

=cut

has name => (
    is       => 'ro',
    isa      => Str,
);

sub _build_name {
    my ($self) = @_;
    my $user = $self->etcd->name;
    return $user if $user;
    return;
}

=head2 password

=cut

has password => (
    is       => 'ro',
    isa      => Str,
);

sub _build_password {
    my ($self) = @_;
    my $pwd = $self->etcd->password;
    return $pwd if $pwd;
    return;
}

=head1 PUBLIC METHODS

=head2 authenticate

Returns token with valid authentication.

    my $token = $etcd->auth({ name => $user, password => $pass })->authenticate;

=cut

sub authenticate {
    my ( $self, $options ) = @_;
    $self->{endpoint} = '/auth/authenticate';
    $self->{headers}{'Content-Type'} = 'application/json';
    return unless ($self->password && $self->name);
    $self->request;
    my $auth = from_json($self->{response}{content});
    if ($auth && defined  $auth->{token}) {
        $self->etcd->{auth_token} = $auth->{token};
    }
    return;
}

=head2 enable

Enable authentication.

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

Disable authentication, this requires a valid root password.

    $etcd->auth({ name => 'root', $password => $pass })->disable;

=cut

sub disable {
    my ( $self, $options ) = @_;
    $self->{endpoint} = '/auth/disable';
    confess 'root name and password required for ' . __PACKAGE__ . '->disable'
      unless ($self->{password} && $self->{name});
    $self->request;
    return $self;
}

1;
