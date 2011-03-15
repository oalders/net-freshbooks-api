use strict;
use warnings;

package Net::FreshBooks::API::Recurring::AutoBill;

use Net::FreshBooks::API::Recurring::AutoBill::Card;

use Moose;
extends 'Net::FreshBooks::API::Base';

has 'gateway_name' => ( is => 'rw', );

has 'card' => (
    is  => 'rw',
    isa => 'Net::FreshBooks::API::Recurring::AutoBill::Card',
    default =>
        sub { return Net::FreshBooks::API::Recurring::AutoBill::Card->new },
);

sub node_name { return 'autobill' }

# make sure unitialized objects don't make the cut
sub _validates {

    my $self = shift;

    return
           $self->gateway_name
        && $self->card->name
        && $self->card->number
        && $self->card->month
        && $self->card->year;

}

sub _fields {
    return {
        gateway_name => { is => 'rw' },
        card         => {
            is           => 'rw',
            made_of      => 'Net::FreshBooks::API::Recurring::AutoBill::Card',
            presented_as => 'object',
        },
    };
}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: Adds AutoBill support to FreshBooks Recurring Items

=head1 SYNOPSIS

Autobill objects can be created via a recurring item:
    
    my $autobill = $recurring_item->autobill;
    
If you want options, you can also do it the hard way:
    
    my $autobill = Net::FreshBooks::API::Recurring::AutoBill->new;
    ... set autobill params ...
    $recurring_item->autobill( $autobill );
    
If you like lots of arrows:

    $recurring_item->autobill->card->expiration->month(12);
    
In summary:

    my $autobill = $recurring_item->autobill;
    $autobill->gateway_name('PayPal Payflow Pro');
    $autobill->card->name('Tim Toady');
    $autobill->card->number('4111 1111 1111 1111');
    $autobill->card->expiration->month(12);
    $autobill->card->expiration->year(2015);
    
    $recurring_item->create;

=head2 gateway name

Case insensitive gateway name from Gateway list (Must be auto-bill enabled).

    $autobill->gateway_name('PayPal Payflow Pro');

=head2 card

Returns a Net::FreshBooks::API::Recurring::AutoBill::Card object

    my $cardholder_name = $autobill->card->name;
    
    # This syntax follows the format of the XML request

    $autobill->card->name('Tim Toady');
    $autobill->card->number('4111 1111 1111 1111');
    $autobill->card->expiration->month(12);
    $autobill->card->expiration->year(2015);
    
    # This alternate syntax is less verbose
    $autobill->card->name('Tim Toady');
    $autobill->card->number('4111 1111 1111 1111');
    $autobill->card->month(12);
    $autobill->card->year(2015);
    
=cut
