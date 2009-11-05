#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dump qw( dump );
use DateTime;
use Test::More;

plan -r 't/config.pl' && require('t/config.pl')
    ? ( tests => 64 )
    : ( skip_all => "Need test connection details in t/config.pl"
        . " - see t/config_sample.pl for details" );

use_ok 'Net::FreshBooks::API';

# create the FB object
my $fb = Net::FreshBooks::API->new(
    {   auth_token   => FBTest->get('auth_token'),
        account_name => FBTest->get('account_name'),

        #verbose     => 1,
    }
);

ok $fb, "created the FB object";
can_ok( $fb, 'recurring' );

my $recurring = $fb->recurring;

isa_ok( $recurring, "Net::FreshBooks::API::Recurring" );

my $client = $fb->client->list->next;

my $list = $fb->recurring->list( {} );

ok( $list, "got a list of recurring items" );

my $line = Net::FreshBooks::API::InvoiceLine->new(
    {   name         => "Widget",
        description  => "Net::FreshBooks::API Widget",
        unit_cost    => '1.99',
        quantity     => 1,
        tax1_name    => "GST",
        tax1_percent => 5,
    }
);

ok( $line, "created a line item" );
isa_ok( $line, "Net::FreshBooks::API::InvoiceLine" );

require_ok('Net::FreshBooks::API::Base');
my $base              = Net::FreshBooks::API::Base->new;
my $frequency_cleanup = $base->_frequency_cleanup;

# test each individual frequency to make sure the frequency setting has been
# properly cleaned up before return to FreshBooks
foreach my $frequency ( values %{$frequency_cleanup} ) {

    my $created = $recurring->create(
        {   client_id => $client->client_id,
            date      => DateTime->now->add( days => 2 )->ymd,
            frequency => $frequency,
            lines     => [$line],
            notes     => 'Created by Net::FreshBooks::API',
        }
    );

    ok( $created, "created a recurring item" );
    isa_ok( $created, 'Net::FreshBooks::API::Recurring' );

    ok( $created->recurring_id,
        "got recurring id: " . $created->recurring_id );
    $created->po_number(9999);
    ok( $created->update(), "could update recurring item" );

    my $get = $recurring->get( { recurring_id => $created->recurring_id } );
    ok( $get, "can get the recurring item" );

    cmp_ok( $get->po_number, '==', 9999,
        "po_number has been correctly updated" );
    ok( $get->delete, "able to delete the recurring item" );
}

