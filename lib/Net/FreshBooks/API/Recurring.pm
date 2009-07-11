package Net::FreshBooks::API::Recurring;

use strict;
use warnings;

use base 'Net::FreshBooks::API::Invoice';

use Net::FreshBooks::API::InvoiceLine;

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );

sub fields {
    
    return {
        client_id          => { mutable => 1, },

        date               => { mutable => 1, },
        po_number          => { mutable => 1, },
        discount           => { mutable => 1, },
        notes              => { mutable => 1, },
        terms              => { mutable => 1, },

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

        occurrences        => { mutable => 1, },
        frequency          => { mutable => 1, },
        stopped            => { mutable => 1, },
        send_email         => { mutable => 1, },
        send_snail_mail    => { mutable => 1, },
    
    };
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


1;
