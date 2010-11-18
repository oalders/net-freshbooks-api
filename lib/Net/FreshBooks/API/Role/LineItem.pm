use strict;
use warnings;

package Net::FreshBooks::API::Role::LineItem;

use Moose::Role;
use Net::FreshBooks::API::InvoiceLine;

sub add_line {
    my $self      = shift;
    my $line_args = shift;

    push @{ $self->{lines} ||= [] },
        Net::FreshBooks::API::InvoiceLine->new($line_args);

    return 1;
}

1;
