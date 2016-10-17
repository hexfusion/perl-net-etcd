use utf8;
package Etcd3::Auth;

=encoding utf8

=head1 NAME

Etcd3::Auth

=cut

our $VERSION = '0.003';

=head1 DESCRIPTION

Authentication

=cut

=head1 SYNOPSIS

    # enable auth
    $etcd->user_add

    # add user
    $etcd->user_add( { name => 'samba', password =>'P@$$' });

    # add role
    $etcd->role_add( { name => 'myrole' });

    # grant role
    $etcd->grant_role( { user => 'samba', role => 'myrole' });

=cut

1;
