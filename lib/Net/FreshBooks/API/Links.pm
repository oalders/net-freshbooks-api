use strict;
use warnings;

package Net::FreshBooks::API::Links;

use Moose;
extends 'Net::FreshBooks::API::Base';

my $fields = _fields();
foreach my $method ( keys %{$fields} ) {
    has $method => (  is => $fields->{$method}->{mutable} ? 'rw' : 'ro' );
}

sub _fields {
    return {
        client_view => { mutable => 0, },
        view        => { mutable => 0, },
        edit        => { mutable => 0, },
    };
}

__PACKAGE__->meta->make_immutable();

1;

=pod

=head1 DESCRIPTION

The methods on this object all return FreshBooks URLs.

=head1 SYNOPSIS

    my $fb = Net::FreshBooks::API->new(...);
    my $invoice = $fb->invoice->get({ invoice_id => $invoice_id });
    my $links = $invoice->links;

    print "Send this link to client: " . $links->client_view;

    my $client = $fb->client->get({ client_id => $client_id });
    print "Client view: " . $client->links->client_view;

=head2 client_view

    Provided for invoice and client links.

=head2 view

    Provided for invoice and client links.

=head2 edit

    Provided for invoice links.

=head2 statement

    Provided for client links.

=cut