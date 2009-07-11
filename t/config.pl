package FBTest;

use strict;
use warnings;

my %CONFIG = (
    test_email   => 'olaf@raybec.com',
    account_name => 'netfreshbooksapi',
    auth_token   => '421e839d73a13c7936e2f91822cff121',
);

sub get {
    my $class = shift;
    my $key   = shift;
    return $CONFIG{$key};
}

1;
