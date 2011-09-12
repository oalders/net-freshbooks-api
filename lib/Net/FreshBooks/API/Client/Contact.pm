use strict;
use warnings;

package Net::FreshBooks::API::Client::Contact;

use Moose;
extends 'Net::FreshBooks::API::Base';

has $_ => ( is => _fields()->{$_}->{is} ) for sort keys %{ _fields() };

sub _fields {
    return {
        contact_id  => { is => 'ro' },
        username    => { is => 'ro' },
        first_name  => { is => 'ro' },
        last_name   => { is => 'ro' },
        email   => { is => 'ro' },
        phone_1   => { is => 'ro' },
        phone_2   => { is => 'ro' },
    };
}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: Provides FreshBooks Link objects to Clients and Invoices

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

    Provided for invoice, client and estimate links.

=head2 view

    Provided for invoice and client links.

=head2 edit

    Provided for invoice links.

=head2 statement

    Provided for client links.

=cut
