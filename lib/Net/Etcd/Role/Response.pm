use utf8;

package Net::Etcd::Role::Response;

use strict;
use warnings;

use Moo::Role;
use JSON;
use MIME::Base64;
use Data::Dumper;

use namespace::clean;

=encoding utf8

=head1 NAME

Net::Etcd::Role::Response

=cut

our $VERSION = '0.020';

=head2 get_value

returns single decoded value or the first.

=cut

sub get_value {
    my ($self)   = @_;
    my $response = $self->response;
    my $content  = from_json( $response->{content} );

    #print STDERR Dumper($content);
    my $value = $content->{kvs}->[0]->{value};
    $value or return;
    return decode_base64($value);
}

=head2 all

returns list containing for example:

  {
    'mod_revision' => '3',
    'version' => '1',
    'value' => 'bar',
    'create_revision' => '3',
    'key' => 'foo0'
  }

where key and value have been decoded for your pleasure.

=cut

sub all {
    my ($self)   = @_;
    my $response = $self->response;
    my $content  = from_json( $response->{content} );
    my $kvs      = $content->{kvs};
    for my $row (@$kvs) {
        $row->{value} = decode_base64( $row->{value} );
        $row->{key}   = decode_base64( $row->{key} );
    }
    return $kvs;
}

=head2 check_hdr

check response header then define success and retry_auth.

=cut

sub check_hdr {
    my ( $self, $status ) = @_;
    my $success = $status == 200 ? 1 : 0;
    $self->{response}{success} = $success;
    $self->{retry_auth}++ if $status == 401;
    return;
}

1;
