use strict;
use warnings;

package Net::FreshBooks::API::Recurring::AutoBill::Card::Expiration;

use Moose;
extends 'Net::FreshBooks::API::Base';

has $_ => ( is => _fields()->{$_}->{is} ) for sort keys %{ _fields() };

sub node_name { return 'expiration' }

sub _fields {
    return {
        month => { is => 'rw' },
        year  => { is => 'rw' },
    };
}

# make sure unitialized objects don't make the cut
sub _validates {

    my $self = shift;

    return ( $self->month && $self->year );

}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: FreshBooks Autobill Credit Card Expiration access
