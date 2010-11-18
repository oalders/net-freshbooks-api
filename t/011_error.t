#!/usr/bin/env perl

use strict;
use Test::More tests => 2;

require_ok( 'Net::FreshBooks::API::Error' );
my $error = Net::FreshBooks::API::Error->new;

can_ok( $error, 'die_on_server_error', 'handle_server_error', 'last_server_error' ); 


