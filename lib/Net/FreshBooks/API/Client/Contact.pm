use strict;
use warnings;

package Net::FreshBooks::API::Client::Contact;

use Moose;
extends 'Net::FreshBooks::API::Base';

has $_ => ( is => _fields()->{$_}->{is} ) for sort keys %{ _fields() };

sub node_name { return 'contact' }

sub _fields {
    return {
        contact_id => { is => 'ro' },
        username   => { is => 'ro' },
        first_name => { is => 'ro' },
        last_name  => { is => 'ro' },
        email      => { is => 'ro' },
        phone1     => { is => 'ro' },
        phone2     => { is => 'ro' },
    };
}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: Provides FreshBooks Contact objects to Clients and Invoices

=pod

=head1 DESCRIPTION

Objects support the following methods: contact_id, username, first_name,
last_name, email, phone1 and phone2.

=head1 SYNOPSIS

    my $fb = Net::FreshBooks::API->new(...);
    my $client = $fb->client->get({ client_id => $client_id });

    foreach my $contact ( @{$invoice->contacts} ) {
        print $contact->first_name, "\n";
    }

=cut
