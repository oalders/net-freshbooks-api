package Net::FreshBooks::API::InvoiceLine;
use base 'Net::FreshBooks::API::Base';

use strict;
use warnings;

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );

sub fields {
    return {
        amount       => { mutable => 0, },
        name         => { mutable => 1, },
        description  => { mutable => 1, },
        unit_cost    => { mutable => 1, },
        quantity     => { mutable => 1, },
        tax1_name    => { mutable => 1, },
        tax2_name    => { mutable => 1, },
        tax1_percent => { mutable => 1, },
        tax2_percent => { mutable => 1, },
    };
}

sub node_name { return 'line' };

1;
