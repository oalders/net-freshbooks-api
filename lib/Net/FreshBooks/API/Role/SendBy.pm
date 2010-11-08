use strict;
use warnings;

package Net::FreshBooks::API::Role::SendBy;

use Moose::Role;
use Data::Dump qw( dump );

sub send_by_email {
    my $self = shift;
    return $self->_send_using( 'sendByEmail' );
}

sub send_by_snail_mail {
    my $self = shift;
    return $self->_send_using( 'sendBySnailMail' );
}

sub _send_using {
    my $self = shift;
    my $how  = shift;

    my $method   = $self->method_string( $how );
    my $id_field = $self->id_field;

    my $res = $self->send_request(
        {   _method   => $method,
            $id_field => $self->$id_field,
        }
    );

    # refetch the estimate so that the flags are updated.
    $self->get( { $id_field => $self->$id_field } );

    return 1;
}

1;
