package FBTest;

use strict;
use warnings;

my %CONFIG = (
    test_email   => 'olaf@raybec.com',
    account_name => 'netfreshbooksapi',
    auth_token   => 'd2d6c5a50b023d95e1c804416d1ec15d',
);

sub get {
    my $class = shift;
    my $key   = shift;
    return $CONFIG{$key};
}

1;
