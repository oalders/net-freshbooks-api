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
    
    my $api = Net::FreshBooks::API->new( %tokens, verbose => 1 );
    isa_ok( $api, 'Net::FreshBooks::API' );
    ok( !$api->_oauth_ok, "oauth object does not yet exist");
    
    can_ok( $api, 'oauth' );
    
    isa_ok( $api->oauth, 'Net::FreshBooks::API::OAuth');
    ok( $api->_oauth_ok, "oauth object should exist now");
    ok( !$api->oauth->authorized, "should not be authorized" );
    ok( !$api->_oauth_authorized, "should not be authorized" );
    
    if ( exists $ENV{'FB_ACCESS_TOKEN'} && exists $ENV{'FB_ACCESS_TOKEN_SECRET'} ) {
        $api->oauth->access_token( $ENV{'FB_ACCESS_TOKEN'} );
        $api->oauth->access_token_secret( $ENV{'FB_ACCESS_TOKEN_SECRET'} );
    }
    
    ok( $api->oauth->authorized, "is now authorized" );
    ok( $api->_oauth_authorized, "is now authorized" );
    
}
