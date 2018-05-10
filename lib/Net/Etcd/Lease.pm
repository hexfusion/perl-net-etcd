use utf8;
package Net::Etcd::Lease;

use strict;
use warnings;

use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use Carp;
use JSON;
use Data::Dumper;

use Moo;
with 'Net::Etcd::Role::Actions';
use namespace::clean;

=head1 NAME

Net::Etcd::Lease

=cut

our $VERSION = '0.020';

=head1 DESCRIPTION

LeaseGrant creates a lease which expires if the server does not receive a keepAlive within
a given time to live period. All keys attached to the lease will be expired and deleted if
the lease expires. Each expired key generates a delete event in the event history.

=head1 ACCESSORS

=head2 endpoint

=cut

has endpoint => (
    is      => 'rwp',
    isa     => Str,
);

=head2 TTL

TTL is the advisory time-to-live in seconds.

=cut

has TTL => (
    is       => 'ro',
    isa      => Str,
);

=head2 ID

ID is the requested ID for the lease. If ID is set to 0, the lessor chooses an ID.

=cut

has ID => (
    is       => 'ro',
    coerce   => sub { return $_[0]; },
);

=head2 keys

keys is true to query all the keys attached to this lease.

=cut

has keys => (
    is       => 'ro',
    isa      => Bool,
    coerce => sub { no strict 'refs'; return $_[0] ? JSON::true : JSON::false }
);

=head1 PUBLIC METHODS

=head2 grant

LeaseGrant creates a lease which expires if the server does not receive a keepAlive within
a given time to live period. All keys attached to the lease will be expired and deleted if
the lease expires. Each expired key generates a delete event in the event history.


    $etcd->lease({ ID => 7587821338341002662,  TTL => 20 })->grant

=cut

sub grant {
    my $self = shift;
    $self->{endpoint} = '/lease/grant';
    confess 'TTL and ID are required for ' . __PACKAGE__ . '->grant'
      unless ($self->{ID} &&  $self->{TTL});
    my $resp = $self->request;
    my $data = $resp->content;
    print STDERR Dumper($data);
    my $result = $data->{result};

    return Net::Etcd::LeaseResponse->new(%$data);
}

=head2 revoke

LeaseRevoke revokes a lease. All keys attached to the lease will expire and be deleted.

    $etcd->lease({{ ID => 7587821338341002662 })->revoke

=cut

sub revoke {
    my $self = shift;
    $self->{endpoint} = '/kv/lease/revoke';
    confess 'ID is required for ' . __PACKAGE__ . '->revoke'
      unless $self->{ID};
    my $resp = $self->request;
    my $data = $resp->content;
    print STDERR Dumper($data);
    my $result = $data->{result};

    return Net::Etcd::LeaseResponse->new(%$data);
}

=head2 ttl

LeaseTimeToLive retrieves lease information.

    $etcd->lease({{ ID => 7587821338341002662, keys => 1 })->ttl

=cut

sub ttl {
    my $self = shift;
    $self->{endpoint} = '/kv/lease/timetolive';
    confess 'ID is required for ' . __PACKAGE__ . '->ttl'
      unless $self->{ID};
    my $resp = $self->request;
    my $data = $resp->content;
    print STDERR Dumper($data);
    my $result = $data->{result};

    return Net::Etcd::LeaseResponse->new(%$data);

}


=head2 keepalive

LeaseKeepAlive keeps the lease alive by streaming keep alive requests from the client
to the server and streaming keep alive responses from the server to the client."

    $etcd->lease({{ ID => 7587821338341002662 })->keepalive

=cut

sub keepalive {
    my $self = shift;
    $self->{endpoint} = '/lease/keepalive';
    confess 'ID is required for ' . __PACKAGE__ . '->keepalive'
      unless $self->{ID};
    my $resp = $self->request;
    my $data = $resp->content;
    print STDERR Dumper($data);
    my $result = $data->{result};

    return Net::Etcd::LeaseResponse->new(%$data);
}

=head2 leases
lists all existing leases.

    $etcd->lease()->leases

=cut

sub leases {
    my $self = shift;
    $self->{endpoint} = '/kv/lease/leases';
    $self->{json_args} = '{}';
    my $resp = $self->request;
    my $data = $resp->content;
    print STDERR Dumper($data);
    my $result = $data->{result};

    return Net::Etcd::LeaseResponse->new(%$data);
}

package Net::Etcd::LeaseResponse;

use strict;
use warnings;

use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use Carp;
use JSON;

use Moo;
use namespace::clean;
with 'Net::Etcd::Role::Response';

=head1 NAME

Net::Etcd::LeaseResponse

=cut

=head1 ACCESSORS

=head2 TTL

TTL is the advisory time-to-live in seconds.

=cut

has TTL => (
    is       => 'ro',
    isa      => Str,
);

=head2 ID

ID is the requested ID for the lease. If ID is set to 0, the lessor chooses an ID.

=cut

has ID => (
    is       => 'ro',
    isa      => Int,
);

=head2 grantedTTL 

GrantedTTL is the initial granted time in seconds upon lease creation/renewal.

=cut

has grantedTTL => (
    is       => 'ro',
    isa      => Int,
);

=head2 keys 

Keys is the list of keys attached to this lease.

=cut

has keys => (
    is       => 'ro',
    isa      => Int,
);

=head2 leases

(slice of) LeaseStatus

=cut

has leases => (
    is       => 'ro',
);

=head2 header

Response header

=cut

has header => (
    is       => 'ro',
    isa      => HashRef,
);

=head2 error 

error message

=cut

has error => (
    is       => 'ro',
    isa      => Str,
);

1;
