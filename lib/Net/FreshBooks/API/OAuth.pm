use strict;
use warnings;

package Net::FreshBooks::API::OAuth;

use base qw(Net::OAuth::Simple);

use Carp qw( croak );
use Data::Dump qw( dump );
use Params::Validate qw(:all);

sub new {

    my $class  = shift;
    my %tokens = @_;

    foreach my $key ( 'consumer_secret', 'consumer_key' ) {
        if ( !exists $tokens{$key} ) {
            croak( "$key required as an argument to new()" );
        }
    }

    my $url = 'https://' . $tokens{consumer_key} . '.freshbooks.com/oauth';

    my %create = (
        tokens           => \%tokens,
        protocol_version => '1.0a',
        urls             => {
            authorization_url => $url . '/oauth_authorize.php',
            request_token_url => $url . '/oauth_request.php',
            access_token_url  => $url . '/oauth_access.php',
        },
        signature_method => 'PLAINTEXT',
    );

    return $class->SUPER::new( %create );

}

1;
