#!/usr/bin/perl
 
use Test::Pod::Coverage tests => 2;
use lib '../lib';
 
pod_coverage_ok( 'Net::FreshBooks::API' );
pod_coverage_ok( 'Net::FreshBooks::API::Base' );
