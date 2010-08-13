NAME
    Net::FreshBooks::API - Easy OO access to the FreshBooks.com API

VERSION
    version 0.11

SYNOPSIS
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

    See also Net::FreshBooks::API::Base for other available methods, such as
    create, update, get, list and delete.

DESCRIPTION
    <http://www.freshbooks.com> is a website that lets you create, send and
    manage invoices. This module is an OO abstraction of their API that lets
    you work with Clients, Invoices etc as if they were standard Perl
    objects.

    Repository: <http://github.com/oalders/net-freshbooks-api/tree/master>

METHODS
  new
    Create a new API object.

        my $fb = Net::FreshBooks::API->new(
            {   account_name => 'account_name',
                auth_token   => '123...def',
            }
        );

  client
    Returns a Net::FreshBooks::API::Client object. The following methods are
    available, as documented in the FreshBooks API:

   client->create
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

    These changes will not be reflected in your FreshBooks account until you
    call the update() method, which is described below.

   client->update
        # take the client object created above
        # we can now make changes to the client and save them
        $client->organization('Perl Foundation');
        $client->update;

        # or more quickly
        $client->update( { organization => 'Perl Foundation', } );

   client->get
        # fetch a client based on a FreshBooks client_id
        my $client = $fb->client->get({ client_id => $client_id });

   client->delete
        # fetch a client and then delete it
        my $client = $fb->client->get({ client_id => $client_id });
        $client->delete;

   client->list
    Returns n Net::FreshBooks::API::Iterator object. Currently, all list()
    functionality defaults to 15 items per page.

        #list all active clients
        my $clients = $fb->client->list();

        print $clients->total . " active clients\n";
        print $clients->pages . " pages of results\n";

        while ( my $client = $clients->next ) {
            print join( "\t", $client->client_id, $client->first_name, $client->last_name ) . "\n";
        }

    To override the default pagination:

        my $clients = $fb->client->list({ page => 2, per_page => 35 });

    See

  invoice
    Create a new Net::FreshBooks::API::Invoice object.

   invoice->create
    Create an invoice in the FreshBooks system.

    my $invoice = $fb->invoice->create({...});

   invoice->add_line
    Create a new Net::FreshBooks::API::InvoiceLine object and add it to the
    end of the list of lines

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

   invoice->send_by_email
    Send the invoice by email.

      my $result = $invoice->send_by_email();

   invoice->send_by_snail_mail
    Send the invoice by snail mail.

      my $result = $invoice->send_by_snail_mail();

   invoice->update
    Please see client->update for an example of how to use this method.

   invoice->get
        my $invoice = $fb->invoice->get({ invoice_id => $invoice_id });

   invoice->delete
        my $invoice = $fb->invoice->get({ invoice_id => $invoice_id });
        $invoice->delete;

   invoice->links
    Returns an object with three methods. Each method returns a FreshBooks
    URL.

   invoice->links->client_view
        print "send this url to client: " . $invoice->links->client_view;

   invoice->links->view
        print "view invoice in my account: " . $invoice->links->view;

   invoice->links->edit
        print "edit invoice in my account: " . $invoice->links->edit;

   invoice->list
    Returns a Net::FreshBooks::API::Iterator object.

        # list unpaid invoices
        my $invoices = $fb->invoice->list({ status => 'unpaid' });

        while ( my $invoice = $invoices->list ) {
            print $invoice->invoice_id, "\n";
        }

   invoice->lines
    Returns an ARRAYREF of Net::FreshBooks::API::InvoiceLine objects

        foreach my $line ( @{ $invoice->lines } ) {
            print $line->amount, "\n";
        }

  payment
    Create a new Net::FreshBooks::API::Payment object.

   payment->create
    Create a new payment in the FreshBooks system

        my $payment = $fb->payment->create({...});

   payment->update
    Please see client->update for an example of how to use this method.

   payment->get
        my $payment = $fb->payment->get({ payment_id => $payment_id });

   payment->delete
        my $payment = $fb->payment->get({ payment_id => $payment_id });
        $payment->delete;

   payment->list
    Returns a Net::FreshBooks::API::Iterator object.

        my $payments = $fb->payment->list;
        while ( my $payment = $payments->list ) {
            print $payment->payment_id, "\n";
        }

  recurring
    Create a new Net::FreshBooks::API::Recurring object.

   recurring->create
        my $recurring = $fb->recurring->create({...});

   recurring->update
    Please see client->update for an example of how to use this method.

   recurring->get
        my $item = $recurring->get({ recurring_id => $recurring_id });

   recurring->delete
        my $item = $recurring->get({ recurring_id => $recurring_id });
        $item->delete;

   recurring->list
    Returns a Net::FreshBooks::API::Iterator object.

        my $recurrings = $fb->recurring->list;
        while ( my $recurring = $recurrings->list ) {
            print $recurring->recurring_id, "\n";
        }

   recurring->lines
    Returns an ARRAYREF of Net::FreshBooks::API::InvoiceLine objects

        foreach my $line ( @{ $recurring->lines } ) {
            print $line->amount, "\n";
        }

  ping
      my $bool = $fb->ping(  );

    Ping the server with a trivial request to see if a connection can be
    made. Returns true if the server is reachable and the authentication
    details are valid.

  service_url
      my $url = $fb->service_url(  );

    Returns a URI object that represents the service URL.

  ua
      my $ua = $fb->ua;

    Return a LWP::UserAgent object to use when contacting the server.

  delete_everything_from_this_test_account
        my $deletion_count
            = $fb->delete_everything_from_this_test_account();

    Deletes all clients, invoices and payments from this account. This is
    convenient when testing but potentially very dangerous. To prevent
    accidential deletions this method has a very long name, and will croak
    if the account name does not end with 'test'.

    As a general rule it is best to put this at the start of your test
    scripts rather than at the end. This will let you inspect your account
    at the end of the test script to see what is left behind.

WARNING
    This code is still under development - any and all patches most welcome.

    The documentation is by no means complete. Feel free to look at the test
    files for more examples of usage.

    Up to this point, only clients, invoices and recurring items have been
    implemented, but other functionality may be added as needed. If you need
    other details, they should be very easy to add. Please get in touch.

AUTHOR CREDITS
    Edmund von der Burg "<evdb@ecclestoad.co.uk"> (Original Author)

    Developed for HinuHinu <http://www.hinuhinu.com/>.

    Recurring item support by:

    Olaf Alders olaf@raybec.com

    Developed for Raybec Communications <http://www.raybec.com>

SEE ALSO
    WWW::FreshBooks::API - an alternative interface to FreshBooks.

    <http://developers.freshbooks.com/overview/> the FreshBooks API
    documentation.

AUTHOR
    Olaf Alders <olaf@wundercounter.com>

COPYRIGHT AND LICENSE
    This software is copyright (c) 2010 by Edmund von der Burg & Olaf
    Alders.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

