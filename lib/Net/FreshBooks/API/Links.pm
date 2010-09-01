use strict;
use warnings;

package Net::FreshBooks::API::Links;

use Moose;
extends 'Net::FreshBooks::API::Base';

my $fields = _fields();
foreach my $method ( keys %{$fields} ) {
    has $method => (  is => $fields->{$method}->{mutable} ? 'rw' : 'ro' );
}

sub _fields {
    return {
        client_view => { mutable => 0, },
        view        => { mutable => 0, },
        edit        => { mutable => 0, },
    };
}

__PACKAGE__->meta->make_immutable();

1;
