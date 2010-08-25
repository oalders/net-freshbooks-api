#!/usr/bin/env perl

use strict;
use Test::More qw( no_plan );

require_ok( 'Net::FreshBooks::API' );
require_ok( 'Net::FreshBooks::API::OAuth' );

my $key    = $ENV{'FB_CONSUMER_KEY'};
my $secret = $ENV{'FB_CONSUMER_SECRET'};

my $tokens_ok = 0;
if ( $key && $secret ) {
    $tokens_ok = 1;
}

SKIP: {
    skip "tokens required", 1 if !$tokens_ok;
    
    my %tokens = (
        consumer_key    => $key,
        consumer_secret => $secret,        
    );

    my $oauth = Net::FreshBooks::API::OAuth->new( %tokens );
    isa_ok( $oauth, 'Net::FreshBooks::API::OAuth' );
    
    my $api = Net::FreshBooks::API->new( %tokens );
    isa_ok( $api, 'Net::FreshBooks::API' );
    isa_ok( $api->oauth, 'Net::FreshBooks::API::OAuth');
    
}
