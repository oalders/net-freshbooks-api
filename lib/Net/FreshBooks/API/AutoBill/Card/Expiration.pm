package Net::FreshBooks::API::AutoBill::Card::Expiration;

use Moose;
extends 'Net::FreshBooks::API::Base';

has $_ => ( is => _fields()->{$_}->{is} ) for sort keys %{ _fields() };

sub node_name { return 'expiration' }

sub _fields {
    return {
        month => { is => 'rw' },
        year  => { is => 'rw' },
    };
}

__PACKAGE__->meta->make_immutable();

1;

# ABSTRACT: FreshBooks Autobill Credit Card Expiration access
