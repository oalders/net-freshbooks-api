use strict;
use warnings;

package Net::FreshBooks::API::Error;

use Moose;
use Carp qw( croak );
use namespace::autoclean;

has 'last_server_error' => ( is => 'rw' );
has 'die_on_server_error' => ( is => 'rw', default => 1 );

sub handle_server_error {
    
    my $self = shift;
    my $msg  = shift;
    
    if ( $self->die_on_server_error ) {
        croak $msg;
    }
    
    $self->last_server_error( $msg );
    
    return;
    
}

1;
