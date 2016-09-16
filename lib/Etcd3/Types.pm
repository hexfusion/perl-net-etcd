package Etcd3::Types;

use Type::Library -base;
use Type::Utils -all;
use Types::Standard -types;

class_type Range, { class => "Etcd3::Range" };

declare_coercion "RangeRequest",
    to_type Range,
    from HashRef, via {
        return Etcd3::Range->new($_)->request
    } ;
1;
