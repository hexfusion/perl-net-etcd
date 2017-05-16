[![Build Status](https://api.travis-ci.org/hexfusion/perl-etcd3.svg?branch=master)](https://travis-ci.org/hexfusion/perl-etcd3)

# NAME

Etcd3

# SYNOPSIS

    Etcd v3.1.0 or greater is required.   To use the v3 API make sure to set environment
    variable ETCDCTL_API=3.  Precompiled binaries can be downloaded at https://github.com/coreos/etcd/releases.

    $etcd = Etcd3->new(); # host: 127.0.0.1 port: 2379
    $etcd = Etcd3->new({ host => $host, port => $port, ssl => 1 });

    # put key
    $result = $etcd->kv({ key =>'foo1', value => 'bar' })->put;

    # get single key
    $key = $etcd->({ key =>'test0' })->range;

    # return single key value or the first in a list.
    $key->get_value

    # get range of keys
    $range = $etcd->range({ key =>'test0', range_end => 'test100' });

    # return array { key => value } pairs from range request.
    my @users = $range->all

    # watch key
    $etcd->range({ key =>'foo', range_end => 'fop' });

# DESCRIPTION

`Etcd3` An object oriented interface to the v3 REST API provided by the etcd grpc gateway.

# ACCESSORS

## host

## port

## username

## password

## ssl

## auth

## api\_root

## api\_prefix

## api\_path

## auth\_token

## headers

# PUBLIC METHODS

## watch

Returns a [Etcd3::Watch](https://metacpan.org/pod/Etcd3::Watch) object.

    $etcd->watch({ key =>'foo', range_end => 'fop' })

## role

    $etcd->role({ role => 'foo' });

## user\_role

Returns a [Etcd3::User::Role](https://metacpan.org/pod/Etcd3::User::Role) object.

    $etcd->user_role({ name => 'samba', role => 'foo' });

## auth\_enable

Currently not available.

## lease

Returns a [Etcd3::Lease](https://metacpan.org/pod/Etcd3::Lease) object.

## user

Returns a [Etcd3::User](https://metacpan.org/pod/Etcd3::User) object.

## kv

Returns a [Etcd3::KV](https://metacpan.org/pod/Etcd3::KV) object.

## configuration

Initialize configuration checks to see it etcd is installed locally.

# AUTHOR

Sam Batschelet, &lt;sbatschelet at mac.com>

# ACKNOWLEDGEMENTS

The [etcd](https://github.com/coreos/etcd) developers and community.

# CAVEATS

The [etcd](https://github.com/coreos/etcd) v3 API is in heavy development and can change at anytime please see
https://github.com/coreos/etcd/blob/master/Documentation/dev-guide/api\_reference\_v3.md
for latest details.

# LICENSE AND COPYRIGHT

Copyright 2017 Sam Batschelet (hexfusion).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
