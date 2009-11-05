#!/usr/bin/env perl

use strict;
use Test::More;

#BEGIN {
#    use Log::Log4perl;
#    Log::Log4perl::init('t/log4perl.conf');
#}

use Net::FreshBooks::API;

plan -r 't/config.pl' && require('t/config.pl')
    ? ( tests => 3 )
    : ( skip_all => "Need test connection details in t/config.pl"
        . " - see t/config_sample.pl for details" );

ok FBTest->get('auth_token') && FBTest->get('account_name'),
    "Could get auth_token and account_name";

my $fb = Net::FreshBooks::API->new(
    {   auth_token   => FBTest->get('auth_token'),
        account_name => FBTest->get('account_name'),
        verbose      => 0,
    }
);
ok $fb, "created the FB object";

ok $fb->ping, "Could ping the Freshbooks server";
