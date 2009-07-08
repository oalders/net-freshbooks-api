package Net::FreshBooks::API::Payment;
use base 'Net::FreshBooks::API::Base';

use strict;
use warnings;

use Net::FreshBooks::API::Links;

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );


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

1;
