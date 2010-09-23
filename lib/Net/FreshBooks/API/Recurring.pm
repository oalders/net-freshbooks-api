use strict;
use warnings;

package Net::FreshBooks::API::Recurring;

use Moose;
extends 'Net::FreshBooks::API::Invoice';

use Net::FreshBooks::API::InvoiceLine;

my $fields = _fields();
foreach my $method ( keys %{$fields} ) {
    has $method => (  is => $fields->{$method}->{mutable} ? 'rw' : 'ro' );
}

sub _fields {

    return {
        recurring_id    => { mutable => 0, },
        frequency       => { mutable => 1, },
        occurrences     => { mutable => 1, },
        stopped         => { mutable => 1, },
        client_id       => { mutable => 1, },
        organization    => { mutable => 1, },
        first_name      => { mutable => 1, },
        last_name       => { mutable => 1, },
        p_street1       => { mutable => 1, },
        p_street2       => { mutable => 1, },
        p_city          => { mutable => 1, },
        p_state         => { mutable => 1, },
        p_country       => { mutable => 1, },
        p_code          => { mutable => 1, },
        po_number       => { mutable => 1, },
        status          => { mutable => 0, },
        amount          => { mutable => 0, },
        date            => { mutable => 1, },
        notes           => { mutable => 1, },
        terms           => { mutable => 1, },
        discount        => { mutable => 1, },
        return_uri      => { mutable => 1, },
        send_snail_mail => { mutable => 1, },
        send_email      => { mutable => 1, },
        lines           => {
            mutable      => 1,
            made_of      => 'Net::FreshBooks::API::InvoiceLine',
            presented_as => 'array',
        },

    };
}


=head1 NAME

Net::FreshBooks::API::Recurring - FreshBooks Recurring Items

=head1 SYNOPSIS

    use Net::FreshBooks::API;
    use Net::FreshBooks::API::InvoiceLine;
    use DateTime;

    # You will not access this module directly, but rather fetch an object via
    # its parent class, Net::FreshBooks::API

    # auth_token and account_name come from FreshBooks
    my $fb = Net::FreshBooks::API->new(
        {   auth_token   => $auth_token,
            account_name => $account_name,
        }
    );

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

=head2 update

Please see client->update for an example of how to use this method.

=head2 get

    my $item = $recurring->get({ recurring_id => $recurring_id });

=head2 delete

    my $item = $recurring->get({ recurring_id => $recurring_id });
    $item->delete;

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

__PACKAGE__->meta->make_immutable();

1;
