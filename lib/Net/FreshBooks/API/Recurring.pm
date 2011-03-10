use strict;
use warnings;

package Net::FreshBooks::API::Recurring;

use Moose;
extends 'Net::FreshBooks::API::Base';
with 'Net::FreshBooks::API::Role::CRUD';
with 'Net::FreshBooks::API::Role::LineItem';

has $_ => ( is => _fields()->{$_}->{is} ) for sort keys %{ _fields() };

sub _fields {

    return {

        amount        => { is => 'ro' },
        client_id     => { is => 'rw' },
        currency_code => { is => 'rw' },
        date          => { is => 'rw' },
        discount      => { is => 'rw' },
        first_name    => { is => 'rw' },
        language      => { is => 'rw' },
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
        status        => { is => 'ro' },
        terms         => { is => 'rw' },
        vat_name      => { is => 'rw' },
        vat_number    => { is => 'rw' },

        # custom fields
        # autobill will need to be an object similar to InvoiceLine
        #autobill        => { ... },
        frequency => { is => 'rw' },
        lines     => {
            is           => 'rw',
            made_of      => 'Net::FreshBooks::API::InvoiceLine',
            presented_as => 'array',
        },
        occurrences     => { is => 'rw' },
        recurring_id    => { is => 'ro' },
        return_uri      => { is => 'rw' },
        send_email      => { is => 'rw' },
        send_snail_mail => { is => 'rw' },
        stopped         => { is => 'rw' },
    };
}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: FreshBooks Recurring Item access

=pod

=head1 SYNOPSIS

    use Net::FreshBooks::API;
    use Net::FreshBooks::API::InvoiceLine;
    use DateTime;

    # You will not access this module directly, but rather fetch an object via
    # its parent class, Net::FreshBooks::API

    my $fb = Net::FreshBooks::API->new({ ... });

    # create a new client
    my $client = $fb->client->create(
        {   first_name   => 'Larry',
            last_name    => 'Wall',
            organization => 'Perl HQ',
            email        => 'larry@example.com',
        }
    );

    # create a recurring item
    use Net::FreshBooks::API;

    my $line = Net::FreshBooks::API::InvoiceLine->new({
        name         => "Widget",
        description  => "Net::FreshBooks::API Widget",
        unit_cost    => '1.99',
        quantity     => 1,
        tax1_name    => "GST",
        tax1_percent => 5,
    });

    # use the client object from the previous example

    my $recurring_item = $fb->recurring->create({
        client_id   => $client->client_id,
        date        => DateTime->now->add( days => 2 )->ymd, # YYYY-MM-DD
        frequency   => 'monthly',
        lines       => [ $line ],
        notes       => 'Created by Net::FreshBooks::API',
    });

    $recurring_item->po_number( 999 );
    $recurring_item->update;

    See also L<Net::FreshBooks::API::Base> for other available methods, such
    as create, update, get, list and delete.

=head2 create

    my $recurring = $fb->recurring->create({...});

=head2 delete

    my $item = $recurring->get({ recurring_id => $recurring_id });
    $item->delete;

=head2 get

    my $item = $recurring->get({ recurring_id => $recurring_id });

=head2 update

    $referring->organization('Perl Foundation');
    $referring->update;

    # or more quickly
    $referring->update( { organization => 'Perl Foundation', } );

=head2 list

Returns a L<Net::FreshBooks::API::Iterator> object.

    my $recurrings = $fb->recurring->list;
    while ( my $recurring = $recurrings->list ) {
        print $recurring->recurring_id, "\n";
    }

=head2 lines

Returns an ARRAYREF of Net::FreshBooks::API::InvoiceLine objects

    foreach my $line ( @{ $recurring->lines } ) {
        print $line->amount, "\n";
    }

=head1 AUTHOR

    Olaf Alders
    CPAN ID: OALDERS
    olaf@raybec.com

=head1 CREDITS

Thanks to Edmund von der Burg for doing all of the hard work to get this
module going and for allowing me to act as a co-maintainer.

Thanks to Raybec Communications L<http://www.raybec.com> for funding my
work on this module and for releasing it to the world.

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut
