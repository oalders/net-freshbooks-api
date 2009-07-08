
#!/usr/bin/env perl

use strict;
use Test::More tests => 6;

use Net::FreshBooks::API;

my $fb = Net::FreshBooks::API->new(
    {   auth_token   => 'auth_token',
        account_name => 'account_name',
    }
);

ok $fb, "created the FB object";

is $fb->service_url->as_string,
    'https://account_name.freshbooks.com/api/2.1/xml-in',
    "Service URL as expected";

my $ua = $fb->ua;
ok $ua, "got the useragent";
like $ua->agent, qr{Net::FreshBooks::API \(v\d+\.\d{2}\)},
    "agent string correctly set";

is_deeply(
    [   $ua->get_basic_credentials(
            $fb->auth_realm, $fb->service_url, undef
        )
    ],
    [ $fb->auth_token, '' ],
    "check that the correct credentials will be used"
);

is_deeply(
    [ $ua->get_basic_credentials( '', $fb->service_url, undef ) ],
    [ $fb->auth_token, '' ],
    "check that the correct credentials will be used (with no realm)"
);

# # logging
# ok ! $fb->log->debug('test of debug level logging'), "logged debug message";
