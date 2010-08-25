use strict;
use warnings;

package Net::FreshBooks::API::Links;

use Moose;
extends 'Net::FreshBooks::API::Base';

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );

sub fields {
    return {
        client_view => { mutable => 0, },
        view        => { mutable => 0, },
        edit        => { mutable => 0, },
    };
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
