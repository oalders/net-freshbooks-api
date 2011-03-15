#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Net::FreshBooks::API;
use Net::FreshBooks::API::AutoBill;

new_ok( 'Net::FreshBooks::API::AutoBill' );
my $autobill = Net::FreshBooks::API::AutoBill->new;

$autobill->gateway_name('PayPal Payflow Pro');
$autobill->card->name('Tim Toady');
$autobill->card->number('4111 1111 1111 1111');
$autobill->card->expiration->month(12);
$autobill->card->expiration->year(2015);

isa_ok( $autobill, 'Net::FreshBooks::API::AutoBill');
isa_ok( $autobill->card, 'Net::FreshBooks::API::AutoBill::Card');
isa_ok( $autobill->card->expiration, 'Net::FreshBooks::API::AutoBill::Card::Expiration');

ok( $autobill->gateway_name, "gateway name: " . $autobill->gateway_name );
ok( $autobill->card->expiration, "card expiration" );
ok( $autobill->card->expiration->month, "card expiration month: " . $autobill->card->expiration->month );
ok( $autobill->card->expiration->year, "card expiration year: " . $autobill->card->expiration->year );

ok( $autobill->card->name, "card name: " . $autobill->card->name );
ok( $autobill->card->number, "card number: " . $autobill->card->number );

diag("alternate syntax");
ok( $autobill->card->month, "card expiration month: " . $autobill->card->expiration->month );
ok( $autobill->card->year, "card expiration year: " . $autobill->card->expiration->year );

done_testing();
