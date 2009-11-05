package Net::FreshBooks::API::Recurring;

use strict;
use warnings;

use base 'Net::FreshBooks::API::Invoice';

use Net::FreshBooks::API::InvoiceLine;

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );

sub fields {

    return {
        client_id => { mutable => 1, },

        date      => { mutable => 1, },
        po_number => { mutable => 1, },
        discount  => { mutable => 1, },
        notes     => { mutable => 1, },
        terms     => { mutable => 1, },

        recurring_id => { mutable => 0, },

        organization => { mutable => 1, },
        first_name   => { mutable => 1, },
        last_name    => { mutable => 1, },
        p_street1    => { mutable => 1, },
        p_street2    => { mutable => 1, },
        p_city       => { mutable => 1, },
        p_state      => { mutable => 1, },
        p_country    => { mutable => 1, },
        p_code       => { mutable => 1, },

        lines => {
            mutable      => 1,
            made_of      => 'Net::FreshBooks::API::InvoiceLine',
            presented_as => 'array',
        },

        # the above lines are shared between invoices and recurring items
        # the lines below are unique to recurring

        occurrences     => { mutable => 1, },
        frequency       => { mutable => 1, },
        stopped         => { mutable => 1, },
        send_email      => { mutable => 1, },
        send_snail_mail => { mutable => 1, },

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

1;
