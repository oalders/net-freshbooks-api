use strict;
use warnings;

package Net::FreshBooks::API::Payment;

use Moose;
extends 'Net::FreshBooks::API::Base';

use Net::FreshBooks::API::Links;

my $fields = fields();
foreach my $method ( keys %{$fields} ) {
    has $method => (  is => $fields->{$method}->{mutable} ? 'rw' : 'ro' );
}

sub fields {
    return {
        payment_id => { mutable => 0, },
        client_id  => { mutable => 1, },
        invoice_id => { mutable => 1, },

        date   => { mutable => 1, },
        amount => { mutable => 1, },
        type   => { mutable => 1, },
        notes  => { mutable => 1, },
    };
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
