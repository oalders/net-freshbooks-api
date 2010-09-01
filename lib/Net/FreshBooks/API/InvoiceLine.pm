use strict;
use warnings;

package Net::FreshBooks::API::InvoiceLine;
use Moose;
extends 'Net::FreshBooks::API::Base';

my $fields = _fields();
foreach my $method ( keys %{$fields} ) {
    has $method => (  is => $fields->{$method}->{mutable} ? 'rw' : 'ro' );
}

sub _fields {
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

sub node_name { return 'line' }

__PACKAGE__->meta->make_immutable();

1;
