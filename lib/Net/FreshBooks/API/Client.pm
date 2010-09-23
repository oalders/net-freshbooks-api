use strict;
use warnings;

package Net::FreshBooks::API::Client;

use Moose;
extends 'Net::FreshBooks::API::Base';

use Net::FreshBooks::API::Links;

my $fields = _fields();
foreach my $method ( keys %{$fields} ) {
    has $method => (  is => $fields->{$method}->{mutable} ? 'rw' : 'ro' );
}


sub _fields {
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

__PACKAGE__->meta->make_immutable();

1;

=head1 DESCRIPTION

This class gives you object to FreshBooks client information.
L<Net::FreshBooks::API> will construct this object for you.

=head1 SYNOPSIS

    my $fb = Net::FreshBooks::API->new({ ... });
    my $client = $fb->client;

=head2 create

    # create a new client
    my $client = $fb->client->create(
        {   first_name   => 'Larry',
            last_name    => 'Wall',
            organization => 'Perl HQ',
            email        => 'larry@example.com',
        }
    );

Once you have a client object, you may set any of the mutable fields by
calling the appropriate method on the object:

    $client->first_name( 'Lawrence' );
    $client->last_name( 'Wahl' );

These changes will not be reflected in your FreshBooks account until you call
the update() method, which is described below.

=head2 update

    # take the client object created above
    # we can now make changes to the client and save them
    $client->organization('Perl Foundation');
    $client->update;

    # or more quickly
    $client->update( { organization => 'Perl Foundation', } );

=head2 get

    # fetch a client based on a FreshBooks client_id
    my $client = $fb->client->get({ client_id => $client_id });

=head2 delete

    # fetch a client and then delete it
    my $client = $fb->client->get({ client_id => $client_id });
    $client->delete;

=head2 links

Returns a L<Net::FreshBooks::API::Links> object, which returns FreshBooks
URLs.

    print "Client view: " . $fb->client->links->client_view;

=head2 list

Returns n L<Net::FreshBooks::API::Iterator> object. Currently,
all list() functionality defaults to 15 items per page.

    #list all active clients
    my $clients = $fb->client->list();

    print $clients->total . " active clients\n";
    print $clients->pages . " pages of results\n";

    while ( my $client = $clients->next ) {
        print join( "\t", $client->client_id, $client->first_name, $client->last_name ) . "\n";
    }

To override the default pagination:

    my $clients = $fb->client->list({ page => 2, per_page => 35 });
