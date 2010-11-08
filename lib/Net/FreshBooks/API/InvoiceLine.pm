use strict;
use warnings;

package Net::FreshBooks::API::InvoiceLine;

use Moose;
extends 'Net::FreshBooks::API::Base';

has $_ => ( is => _fields()->{$_}->{is} ) for sort keys %{ _fields() };

sub node_name { return 'line' }

sub _fields {
    return {
        line_id      => { is => 'ro' },
        amount       => { is => 'ro' },
        name         => { is => 'rw' },
        description  => { is => 'rw' },
        unit_cost    => { is => 'rw' },
        quantity     => { is => 'rw' },
        tax1_name    => { is => 'rw' },
        tax2_name    => { is => 'rw' },
        tax1_percent => { is => 'rw' },
        tax2_percent => { is => 'rw' },
        type         => { is => 'rw' },
    };
}

__PACKAGE__->meta->make_immutable();

1;
