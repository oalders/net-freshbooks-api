use strict;
use warnings;

package Net::FreshBooks::API::Role::Common;

use Moose::Role;
use Carp qw( carp croak );
use Data::Dump qw( dump );

has 'die_on_server_error' => ( is => 'rw', isa => 'Bool', lazy_build => 1, );
has 'last_server_error'   => ( is => 'rw' );
has 'verbose'             => ( is => 'rw', isa => 'Bool', lazy_build => 1 );

has '_return_xml'  => ( is => 'rw', isa => 'Str' );
has '_request_xml' => ( is => 'rw', isa => 'Str' );

sub _build_die_on_server_error { return 1; }
sub _build_verbose             { return 0; }

sub handle_server_error {

    my $self = shift;
    my $msg  = shift;

    if ( $self->die_on_server_error ) {
        croak $msg;
    }

    $self->last_server_error( $msg );

    return;

}

sub _log {    ## no critic

    my $self = shift;
    return if !$self->verbose;

    my ( $level, $message ) = @_;
    $message .= "\n" if $message !~ m{\n/z}x;
    carp "$level: $message";

    return;

}

1;

# ABSTRACT: Roles common to both Base.pm and API.pm

=pod

=head1 SYNOPSIS

These roles are generally for debugging and error handling.

=head2 verbose( 0|1 )

Enable this to direct a lot of extra info the STDOUT

=cut
