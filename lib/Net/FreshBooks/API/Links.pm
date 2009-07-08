package Net::FreshBooks::API::Links;
use base 'Net::FreshBooks::API::Base';

use strict;
use warnings;

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );

sub fields {
    return {
        client_view => { mutable => 0, },
        view        => { mutable => 0, },
        edit        => { mutable => 0, },

        # => { mutable => 0, },
        # => { mutable => 0, },
        # => { mutable => 0, },
    };
}

1;
