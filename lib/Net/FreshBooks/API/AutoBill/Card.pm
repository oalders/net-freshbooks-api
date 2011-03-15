package Net::FreshBooks::API::AutoBill::Card;

use Moose;
extends 'Net::FreshBooks::API::Base';

use Net::FreshBooks::API::AutoBill::Card::Expiration;

has 'expiration' => (
    is => 'rw',
    default =>
        sub { return Net::FreshBooks::API::AutoBill::Card::Expiration->new },
    handles => [ 'month', 'year' ],
);

has 'name' => ( is => 'rw', );

has 'number' => ( is => 'rw', );

sub node_name { return 'card' }

sub _fields {
    return {
        number     => { is => 'rw' },
        name       => { is => 'rw' },
        expiration => {
            is      => 'rw',
            made_of => 'Net::FreshBooks::API::AutoBill::Card::Expiration',
            presented_as => 'object',
        },
    };
}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: FreshBooks Autobill Credit Card access

=pod

=head2 expiration

Returns an Net::FreshBooks::API::AutoBill::Card::Expiration object

=head2 name

Cardholder name

=head2 number

Card number, eg '4111 1111 1111 1111'. Can include spaces, hyphens and other
punctuation marks.

=head1 CONVENIENCE METHODS

=head2 month

The card's 2 digit expiration month. This is a shortcut to the
Net::FreshBooks::API::AutoBill::Card::Expiration object.

    $recurring->autobill->card->month;
    
    # is the same as
    $recurring->autobill->card->expiration->month;

=head2 year

The card's 4 digit expiration year. This is a shortcut to the
Net::FreshBooks::API::AutoBill::Card::Expiration object.

    $recurring->autobill->card->year;
    
    # is the same as
    $recurring->autobill->card->expiration->year;
    
=head1 INTERNAL METHODS

=head2 node_name

Used internally for XML parsing

=cut
