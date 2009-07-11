#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

plan -r 't/config.pl' && require('t/config.pl')
    ? ( tests => 5 )
    : ( skip_all => "Need test connection details in t/config.pl"
        . " - see t/config_sample.pl for details" );

use_ok 'Net::FreshBooks::API';

# create the FB object
my $fb = Net::FreshBooks::API->new(
    {   auth_token   => FBTest->get('auth_token'),
        account_name => FBTest->get('account_name'),
    }
);

ok $fb, "created the FB object";
can_ok( $fb, 'recurring' );

my $recurring = $fb->recurring;

isa_ok( $recurring, "Net::FreshBooks::API::Recurring" );

my $list = $fb->recurring->list( {} );

ok ( $list, "got a list of recurring items" );