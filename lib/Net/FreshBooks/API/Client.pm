use strict;
use warnings;

package Net::FreshBooks::API::Client;

use Moose;
extends 'Net::FreshBooks::API::Base';

use Net::FreshBooks::API::Links;

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );

sub fields {
    return {
        client_id => { mutable => 0, },

        first_name   => { mutable => 1, },
        last_name    => { mutable => 1, },
        organization => { mutable => 1, },

        email      => { mutable => 1, },
        username   => { mutable => 1, },
        password   => { mutable => 1 },
        work_phone => { mutable => 1, },
        home_phone => { mutable => 1, },
        mobile     => { mutable => 1, },
        fax        => { mutable => 1, },

        credit => { mutable => 0, },
        notes  => { mutable => 1, },

        p_street1 => { mutable => 1, },
        p_street2 => { mutable => 1, },
        p_city    => { mutable => 1, },
        p_state   => { mutable => 1, },
        p_country => { mutable => 1, },
        p_code    => { mutable => 1, },

        s_street1 => { mutable => 1, },
        s_street2 => { mutable => 1, },
        s_city    => { mutable => 1, },
        s_state   => { mutable => 1, },
        s_country => { mutable => 1, },
        s_code    => { mutable => 1, },

        links => {
            mutable      => 0,
            made_of      => 'Net::FreshBooks::API::Links',
            presented_as => 'single',
        },
    };
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
