package Etcd3::Range;

use strict;
use warnings;

use Moo;
use Types::Standard qw(Str Int Bool HashRef ArrayRef);
use MIME::Base64;
use JSON;

use namespace::clean;

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

key is the first key for the range. If range_end is not given, the request only looks up key.
the key is encoded with base64.  type bytes

=cut

has key => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce => sub { return encode_base64($_[0],'') }
);

=head2 range_end

range_end is the upper bound on the requested range [key, range_end). If range_end is '\0',
the range is all keys >= key. If the range_end is one bit larger than the given key, then
the range requests get the all keys with the prefix (the given key). If both key and 
range_end are '\0', then range requests returns all keys. the key is encoded with base64.
type bytes

=cut

has range_end => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce => sub { return encode_base64($_[0],'') }
);

=head2 limit

limit is a limit on the number of keys returned for the request. type int64

=cut

has limit => (
    is       => 'ro',
    isa      => Int,
);

=head2 revision

revision is the point-in-time of the key-value store to use for
the range. If revision is less or equal to zero, the range is over
the newest key-value store. If the revision has been compacted,
ErrCompaction is returned as a response. type int64

=cut 

has revision => {
    is    => 'ro',
    isa   => Int,
);

=head2 sort_order

sort_order is the order for returned sorted results.

=cut

has sort_order => (
    is       => 'ro',
    isa      => Int,
);

=head2 sort_target

sort_target is the key-value field to use for sorting.

=cut

has sort_target => (
    is       => 'ro',
    isa      => Str,
);

=head2 serializable

serializable sets the range request to use serializable member-local reads.
Range requests are linearizable by default; linearizable requests have higher
latency and lower throughput than serializable requests but reflect the current
consensus of the cluster. For better performance, in exchange for possible stale
reads, a serializable range request is served locally without needing to reach
consensus with other nodes in the cluster.

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
