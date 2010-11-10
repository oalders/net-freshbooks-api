use strict;
use warnings;

package Net::FreshBooks::API::Estimate;

use Moose;
extends 'Net::FreshBooks::API::Base';
with 'Net::FreshBooks::API::Role::CRUD';
with 'Net::FreshBooks::API::Role::LineItem';
with 'Net::FreshBooks::API::Role::SendBy' =>
    { -excludes => 'send_by_snail_mail' };

has $_ => ( is => _fields()->{$_}->{is} ) for sort keys %{ _fields() };

sub _fields {
    return {

        amount        => { is => 'ro' },
        client_id     => { is => 'rw' },
        currency_code => { is => 'rw' },
        date          => { is => 'rw' },
        discount      => { is => 'rw' },
        first_name    => { is => 'rw' },
        last_name     => { is => 'rw' },
        notes         => { is => 'rw' },
        organization  => { is => 'rw' },
        p_city        => { is => 'rw' },
        p_code        => { is => 'rw' },
        p_country     => { is => 'rw' },
        p_state       => { is => 'rw' },
        p_street1     => { is => 'rw' },
        p_street2     => { is => 'rw' },
        po_number     => { is => 'rw' },
        status        => { is => 'rw' },
        terms         => { is => 'rw' },
        vat_name      => { is => 'rw' },
        vat_number    => { is => 'rw' },

        # custom fields
        estimate_id => { is => 'ro' },
        folder      => { is => 'rw' },
        lines       => {
            is           => 'rw',
            made_of      => 'Net::FreshBooks::API::InvoiceLine',
            presented_as => 'array',
        },
        links => {
            is           => 'ro',
            made_of      => 'Net::FreshBooks::API::Links',
            presented_as => 'single',
        },
        number => { is => 'rw' },

    };
}

__PACKAGE__->meta->make_immutable();

1;

=head1 DESCRIPTION

This class gives you access to FreshBooks invoice information.
L<Net::FreshBooks::API> will construct this object for you.

=head1 SYNOPSIS

    my $fb = Net::FreshBooks::API->new({ ... });
    my $estimate = $fb->estimate;

=head2 create

Create an estimate in the FreshBooks system.

    my $estimate = $fb->estimate->create({...});

=head2 delete

    my $estimate = $fb->estimate->get({ estimate_id => $estimate_id });
    $estimate->delete;

=head2 get

    my $estimate = $fb->estimate->get({ estimate_id => $estimate_id });
    
=head2 update

    $estimate->organization('Perl Foundation');
    $estimate->update;

    # or more quickly
    $estimate->update( { organization => 'Perl Foundation', } );

=head2 add_line

Create a new L<Net::FreshBooks::API::estimateLine> object and add it to the
end of the list of lines

    my $bool = $estimate->add_line(
        {   name         => "Yard Work",          # (Optional)
            description  => "Mowed the lawn.",    # (Optional)
            unit_cost    => 10,                   # Default is 0
            quantity     => 4,                    # Default is 0
            tax1_name    => "GST",                # (Optional)
            tax2_name    => "PST",                # (Optional)
            tax1_percent => 8,                    # (Optional)
            tax2_percent => 6,                    # (Optional)
        }
    );
    
=head2 links

Returns a L<Net::FreshBooks::API::Links> object, which returns FreshBooks
URLs.

    print "send this url to client: " . $estimate->links->client_view;

=head2 list

Returns a L<Net::FreshBooks::API::Iterator> object.

    # list unpaid estimates
    my $estimates = $fb->estimate->list({ status => 'unpaid' });

    while ( my $estimate = $estimates->list ) {
        print $estimate->estimate_id, "\n";
    }

=head2 lines

Returns an ARRAYREF of Net::FreshBooks::API::InvoiceLine objects

    foreach my $line ( @{ $estimate->lines } ) {
        print $line->amount, "\n";
    }

=head2 send_by_email

Send the estimate by email.

  my $result = $estimate->send_by_email();
  
=cut
