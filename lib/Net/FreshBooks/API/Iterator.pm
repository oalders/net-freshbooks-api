use strict;
use warnings;

package Net::FreshBooks::API::Iterator;

use Moose;

use Data::Dump qw( dump );
use Lingua::EN::Inflect qw( PL );
use XML::LibXML ':libxml';

has 'parent_object' => ( is => 'rw' );    # The object we are iterating for
has 'args'          => ( is => 'rw' );    # args used in the search
has 'total'         => ( is => 'rw' );    # The total number of results
has 'pages'         => ( is => 'rw' );    # the number of result pages
has 'item_nodes'    => ( is => 'rw' );    # a list of all items
has 'current_index' => ( is => 'rw' );    # which item we are currently on

=head2 new

    my $iterator = $class->new(
        {   parent_object => $parent_object,
            args         => {...},
        }
    );

Create a new iterator object. As part of creating the iterator a request is sent
to FreshBooks.

=head2 next

    my $next_result = $iterator->next(  );

Returns the next item in the iterator.

=head2 total

Returns the total number of results available, regardless of how many items are
on the current page.

=head2 pages

Returns the total number of result pages

=head2 current_index

The item we are currently on

=cut

sub new {
    my $class = shift;
    my $self = bless shift, $class;

    my $request_args = {
        _method => $self->parent_object->method_string( 'list' ),

        # defaults
        page     => 1,
        per_page => 15,

        %{ $self->args },
    };

    my $list_name = PL( $self->parent_object->api_name );

    my $response = $self->parent_object->send_request( $request_args );
    my ( $list ) = $response->findnodes( "//$list_name" );

    $self->pages( $list->getAttribute( 'pages' ) );
    $self->total( $list->getAttribute( 'total' ) );

    my $parser = XML::LibXML->new();

    my @item_nodes =    #
        map { $parser->parse_string( $_->toString ) }    # recreate
        grep { $_->nodeType eq XML_ELEMENT_NODE }        # filter
        $list->childNodes;

    $self->item_nodes( \@item_nodes );

    return $self;
}

sub next {                                               ## no critic
    ## use critic
    my $self = shift;

    # work out what the current index should be
    my $current_index = $self->current_index;
    $current_index = defined( $current_index ) ? $current_index + 1 : 0;
    $self->current_index( $current_index );

    # check that there is a next item
    # FIXME - add fetching the next page if needed here
    my $next_node = $self->item_nodes->[$current_index];
    return if !$next_node;

    # if we don't clone here, a user who iterates and pushes the returned
    # objects to a list will end up with a list of copies of the last
    # object to be returned
    return $self->parent_object->clone->_fill_in_from_node( $next_node );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
