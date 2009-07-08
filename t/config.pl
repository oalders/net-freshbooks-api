package FBTest;

use strict;
use warnings;

my %CONFIG = (
    test_email   => 'evdb@hinuhinu.com',
    account_name => 'hinuhinutest',
    auth_token   => '0af3d24bff8f7f0d6ccc36864212db7f',
);

sub get {
    my $class = shift;
    my $key   = shift;
    return $CONFIG{$key};
}

1;
