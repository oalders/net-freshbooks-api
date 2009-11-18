package Net::FreshBooks::API;
use base 'Class::Accessor::Fast';

use strict;
use warnings;

our $VERSION = '0.08';

use Carp qw( carp croak );
use URI;
use Data::Dump qw( dump );
use Path::Class;

__PACKAGE__->mk_accessors(
    'account_name',         #
    'auth_token',           #
    'verbose',              #
    'communication_log',    #
    'api_version',          #
    'auth_realm',           #
);

use Net::FreshBooks::API::Client;
use Net::FreshBooks::API::Invoice;
use Net::FreshBooks::API::Payment;
use Net::FreshBooks::API::Recurring;

=head1 NAME

Net::FreshBooks::API - Easy OO access to the FreshBooks.com API

=head1 VERSION

Version 0.08

=head1 SYNOPSIS

    use Net::FreshBooks::API;

    # auth_token and account_name come from FreshBooks
    my $fb = Net::FreshBooks::API->new(
        {   auth_token   => $auth_token,
            account_name => $account_name,
            verbose      => 0, # turn on for XML debugging etc
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

    # we can now make changes to the client and save them
    $client->organization('Perl Foundation');
    $client->update;

    # or more quickly
    $client->update( { organization => 'Perl Foundation', } );

    # create an invoice for this client
    my $invoice = $fb->invoice(
        {   client_id => $client->client_id,
            number    => '00001',
        }
    );

    # add a line to the invoice
    $invoice->add_line(
        {   name      => 'Hawaiian shirt consulting',
            unit_cost => 60,
            quantity  => 4,
        }
    );

    # save the invoice and then send it
    $invoice->create;
    $invoice->send_by_email;

    ############################################
    # create a recurring item
    ############################################

    use Net::FreshBooks::API;
    use Net::FreshBooks::API::InvoiceLine;
    use DateTime;

    # auth_token and account_name come from FreshBooks
    my $fb = Net::FreshBooks::API->new(
        {   auth_token   => $auth_token,
            account_name => $account_name,
        }
    );

    # find the first client returned
    my $client = $fb->client->list->next;

    # create a line item
    my $line = Net::FreshBooks::API::InvoiceLine->new({
        name         => "Widget",
        description  => "Net::FreshBooks::API Widget",
        unit_cost    => '1.99',
        quantity     => 1,
        tax1_name    => "GST",
        tax1_percent => 5,
    });

    # create the recurring item
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

=head1 WARNING

This code is still under development - any and all patches most welcome.

Especially lacking is the documentation - for now you'd better look at the test
file 't/live-test.t' for examples of usage.

Up to this point, only clients, invoices and recurring items have been
implemented, but other functionality may be added as needed.
If you need other details, they should be very easy to add. Please get in
touch.

=head1 DESCRIPTION

L<FreshBooks.com> is a website that lets you create, send and manage invoices.
This module is an OO abstraction of their API that lets you work with Clients,
Invoices etc as if they were standard Perl objects.

Repository: L<http://github.com/oalders/net-freshbooks-api/tree/master>

=head1 METHODS

=head2 new

    my $fb = Net::FreshBooks::API->new(
        {   account_name => 'account_name',
            auth_token   => '123...def',
        }
    );

Create a new API object.

=head2 client

This returns a Net::FreshBooks::API::Client object.  The following methods are
available, as documented in the FreshBooks API:

=head3 client->create

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

=head3 client->update

    # take the client object created above
    # we can now make changes to the client and save them
    $client->organization('Perl Foundation');
    $client->update;

    # or more quickly
    $client->update( { organization => 'Perl Foundation', } );

=head3 client->get

    # or, fetch a client based on its FreshBooks client_id
    my $client = $fb->client->get({ client_id => $client_id });

=head3 client->delete

    # fetch a client and then delete it
    my $client = $fb->client->get({ client_id => $client_id });
    $client->delete;

=head3 client->list

    # or, list all active clients
    my $clients = $fb->client->list();

    while ( my $client = $clients->next ) {
        print join( "\t", $client->client_id, $client->first_name, $client->last_name ) . "\n";
    }


=head2 invoice

Create a new L<Net::FreshBooks::API::Invoice> object.

=head3 invoice->create

Create an invoice in the FreshBooks system.

my $invoice = $fb->invoice->create({...});

=head3 invoice->add_line

Create a new L<Net::FreshBooks::API::InvoiceLine> object and add it to the end
of the list of lines

    my $bool = $invoice->add_line(
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


=head3 invoice->send_by_email

Send the invoice by email.

  my $result = $invoice->send_by_email();

=head3 invoice->send_by_snail_mail

Send the invoice by snail mail.

  my $result = $invoice->send_by_snail_mail();

=head3 invoice->update

Please see client->update for an example of how to use this method.

=head3 invoice->get

    my $invoice = $fb->invoice->get({ invoice_id => $invoice_id });

=head3 invoice->delete

    my $invoice = $fb->invoice->get({ invoice_id => $invoice_id });
    $invoice->delete;

=head3 invoice->list

    my $invoices = $fb->invoice->list;
    while ( my $invoice = $invoices->list ) {
        print $invoice->invoice_id, "\n";
    }

=head2 payment

Create a new L<Net::FreshBooks::API::Payment> object.

=head3 payment->create

Create a new payment in the FreshBooks system

    my $payment = $fb->payment->create({...});

=head3 payment->update

Please see client->update for an example of how to use this method.

=head3 payment->get

    my $payment = $fb->payment->get({ payment_id => $payment_id });

=head3 payment->delete

    my $payment = $fb->payment->get({ payment_id => $payment_id });
    $payment->delete;

=head3 payment->list

    my $payments = $fb->payment->list;
    while ( my $payment = $payments->list ) {
        print $payment->payment_id, "\n";
    }

=head2 recurring

Create a new L<Net::FreshBooks::API::Recurring> object.

=head3 recurring->create

    my $recurring = $fb->recurring->create({...});

=head3 recurring->update

Please see client->update for an example of how to use this method.

=head3 recurring->get

    my $item = $recurring->get({ recurring_id => $recurring_id });

=head3 recurring->delete

    my $item = $recurring->get({ recurring_id => $recurring_id });
    $item->delete;

=head3 recurring->list

    my $recurrings = $fb->recurring->list;
    while ( my $recurring = $recurrings->list ) {
        print $recurring->recurring_id, "\n";
    }


=head2 ping

  my $bool = $fb->ping(  );

Ping the server with a trivial request to see if a connection can be made.
Returns true if the server is reachable and the authentication details are
valid.

=head2 service_url

  my $url = $fb->service_url(  );

Returns a L<URI> object that represents the service URL.

=head2 ua

  my $ua = $fb->ua;

Return a LWP::UserAgent object to use when contacting the server.

=head2 delete_everything_from_this_test_account

    my $deletion_count
        = $fb->delete_everything_from_this_test_account();

Deletes all clients, invoices and payments from this account. This is convenient
when testing but potentially very dangerous. To prevent accidential deletions
this method has a very long name, and will croak if the account name does not
end with 'test'.

As a general rule it is best to put this at the B<start> of your test scripts
rather than at the end. This will let you inspect your account at the end of the
test script to see what is left behind.

=head1 AUTHOR

Edmund von der Burg C<<evdb@ecclestoad.co.uk>>

Developed for HinuHinu L<http://www.hinuhinu.com/>.

Recurring item support by:

Olaf Alders olaf@raybec.com

Developed for Raybec Communications L<http://www.raybec.com>

=head1 LICENCE

Perl

=head1 SEE ALSO

L<WWW::FreshBooks::API> - an alternative interface to FreshBooks.

L<http://developers.freshbooks.com/overview/> the FreshBooks API documentation.

=cut



sub new {
    my $class = shift;
    my $args  = shift;

    croak "Need both an account_name and an auth_token"
        unless $args->{account_name} && $args->{auth_token};

    $args->{api_version} ||= 2.1;
    $args->{auth_realm}  ||= 'FreshBooks';

    # configure the logging
    if ( $args->{verbose} ) {
        if ( ref $args->{verbose} ne 'CODE' ) {
            $args->{verbose} = sub {
                my ( $level, $message ) = @_;
                $message .= "\n" if $message !~ m{\n/z}x;
                carp "$level: $message";
            };
        }
    }
    else {
        $args->{verbose} = sub { 1; };
    }

    if ( $args->{communication_log} ) {
        if ( ref $args->{communication_log} ne 'CODE' ) {
            my $file = file( $args->{communication_log} )->absolute;
            $args->{communication_log} = sub {
                my ( $message ) = @_;
                my $fh = $file->open( 'a' )
                    || croak "Could not open for append: $file";
                $fh->print(
                    $message->as_string . "\n\n" . '-' x 80 . "\n\n" );
            };
        }
    }
    else {
        $args->{communication_log} = sub { 1; };
    }

    return bless {%$args}, $class;
}


sub _log {    ## no critic
    my $self = shift;
    return $self->verbose->( @_ );
}


sub _clog {    ## no critic
    my $self = shift;
    return $self->communication_log->( @_ );
}


sub ping {
    my $self = shift;
    eval { $self->client->list() };

    $self->_log( debug => $@ ? "ping failed: $@" : "ping succeeded" );
    return if $@;
    return 1;
}


sub service_url {
    my $self = shift;

    my $uri
        = URI->new( 'https://'
            . $self->account_name
            . '.freshbooks.com/api/'
            . $self->api_version
            . '/xml-in' );

    return $uri;
}


sub client {
    my $self = shift;
    my $args = shift || {};
    return Net::FreshBooks::API::Client->new( { _fb => $self, %$args } );
}


sub invoice {
    my $self = shift;
    my $args = shift || {};
    return Net::FreshBooks::API::Invoice->new( { _fb => $self, %$args } );
}


sub payment {
    my $self = shift;
    my $args = shift || {};
    return Net::FreshBooks::API::Payment->new( { _fb => $self, %$args } );
}


sub recurring {
    my $self = shift;
    my $args = shift || {};
    return Net::FreshBooks::API::Recurring->new( { _fb => $self, %$args } );
}


my $CACHED_UA = undef;

sub ua {
    my $self = shift;
    return $CACHED_UA if $CACHED_UA;

    my $class = ref( $self ) || $self;
    my $version = $VERSION;

    my $ua = LWP::UserAgent->new(
        agent             => "$class (v$version)",
        protocols_allowed => ['https'],
        keep_alive        => 10,
    );

    $ua->credentials(    #
        $self->service_url->host_port,    # net loc
        $self->auth_realm,                # realm
        $self->auth_token,                # username
        ''                                # password (none - all in username)
    );

    $ua->credentials(                     #
        $self->service_url->host_port,    # net loc
        '',                               # realm (none)
        $self->auth_token,                # username
        ''                                # password (none - all in username)
    );

    return $CACHED_UA = $ua;
}


sub delete_everything_from_this_test_account {

    my $self = shift;

    my $name = $self->account_name;
    croak(    "ERROR: account_name must end with 'test' to use"
            . " the method delete_everything_on_this_test_account"
            . " - your account name is '$name'" )
        if ( $name !~ m{ test \z }x && $name ne 'netfreshbooksapi' );

    my $delete_count = 0;

    # note: 'payments' can't be deleted
    my @names_to_delete = qw( invoice client );

    # clear out all existing clients etc on this account.
    foreach my $object_name ( @names_to_delete ) {
        my $objects_to_delete = $self->$object_name->list();
        while ( my $obj = $objects_to_delete->next ) {
            $obj->delete;
            $delete_count++;
        }
    }

    return $delete_count;
}


1;
