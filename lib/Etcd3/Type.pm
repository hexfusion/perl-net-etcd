package Etcd3::Type;

use Type::Library -base;
use Type::Utils -all;
use Types::Standard -types;

=head2 Range, RangeRequest

=cut

class_type Range, { class => "Etcd3::Range" };

declare_coercion "RangeRequest",
    to_type Range,
    from HashRef, via {
        return Etcd3::Range->new($_)->init
    };

=head2 Put, PutRequest

=cut

class_type Put, { class => "Etcd3::Put" };

declare_coercion "PutRequest",
    to_type Put,
    from HashRef, via {
        return Etcd3::Put->new($_)->init
    };

=head2 Authenticate, AuthenticateRequest

=cut

class_type Authenticate, { class => "Etcd3::Authenticate" };

declare_coercion "AuthenticateRequest",
    to_type Authenticate,
    from HashRef, via {
        return Etcd3::Authenticate->new($_)->init
    };

=head2 DeleteRange, DeleteRangeRequest

=cut

class_type DeleteRange, { class => "Etcd3::DeleteRange" };

declare_coercion "DeleteRangeRequest",
    to_type DeleteRange,
    from HashRef, via {
        return Etcd3::DeleteRange->new($_)->init
    };

=head2 Watch, WatchRequest

=cut

class_type Watch, { class => "Etcd3::Watch" };

declare_coercion "WatchRequest",
    to_type Watch,
    from HashRef, via {
        return Etcd3::Watch->new($_)->init
    };



1;
