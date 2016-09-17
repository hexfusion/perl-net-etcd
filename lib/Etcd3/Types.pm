package Etcd3::Types;

use Type::Library -base;
use Type::Utils -all;
use Types::Standard -types;

=head2 Range, RangeRequest

=cut

class_type Range, { class => "Etcd3::Range" };

declare_coercion "RangeRequest",
    to_type Range,
    from HashRef, via {
        return Etcd3::Range->new($_)->request
    };

=head2 Put, PutRequest

=cut

class_type Put, { class => "Etcd3::Put" };

declare_coercion "PutRequest",
    to_type Put,
    from HashRef, via {
        return Etcd3::Put->new($_)->request
    };

=head2 Authenticate, AuthenticateRequest

=cut

class_type Authenticate, { class => "Etcd3::Authenticate" };

declare_coercion "AuthenticateRequest",
    to_type Put,
    from HashRef, via {
        return Etcd3::Authenticate->new($_)->request
    };


1;
