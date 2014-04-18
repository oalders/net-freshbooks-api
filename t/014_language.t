#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Net::FreshBooks::API;
use Test::WWW::Mechanize;

plan -r 't/config.pl' && require( 't/config.pl' )
    ? ( tests => 7 )
    : ( skip_all => "Need test connection details in t/config.pl"
        . " - see t/config_sample.pl for details" );

# create the FB object
my $fb = Net::FreshBooks::API->new(
    {   auth_token   => FBTest->get( 'auth_token' ),
        account_name => FBTest->get( 'account_name' ),
        verbose      => 0,
    }
);

ok $fb, "created the FB object";

isa_ok( $fb->language, "Net::FreshBooks::API::Language" );
my $langs = $fb->language->get_all();
ok( $langs, "got languages" );

foreach my $lang ( @{ $fb->language->get_all() } ) {
    diag $lang->code . ": " . $lang->name;
}

#diag explain $langs;
ok( ( scalar @{$langs} != 0 ),
    "languages in test account: " . scalar @{$langs} );
dies_ok( sub { $fb->language->get }, "get not implemented" );
my $list = $fb->language->list;

ok( $list->total, "got total via list: " . $list->total );
ok( $list->pages, "got pages via list: " . $list->pages );
