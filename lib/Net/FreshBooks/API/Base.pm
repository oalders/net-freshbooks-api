package Net::FreshBooks::API::Base;
use base 'Class::Accessor::Fast';

use strict;
use warnings;

use Data::Dumper;
use Carp;
use Clone qw(clone);

use Net::FreshBooks::API::Iterator;

use XML::LibXML ':libxml';
use LWP::UserAgent;

my %plural_to_singular = (
    clients  => 'client',
    invoices => 'invoice',
    lines    => 'line',
    payments => 'payment',
    nesteds  => 'nested',    # for testing
);

__PACKAGE__->mk_accessors('_fb');

=head2 new_from_node

  my $new_object = $class->new_from_node( $node );

Create a new object from the node given.

=cut

sub new_from_node {
    my $class = shift;
    my $node  = shift;

    my $self = bless {}, $class;

    $self->_fill_in_from_node($node);

    return $self;
}

=head2 copy

  my $new_object = $self->copy(  );

Returns a new object with the fb object set on it.

=cut

sub copy {
    my $self  = shift;
    my $class = ref $self;
    return $class->new( { _fb => $self->_fb } );
}

=head2 create

  my $new_object = $self->create( \%args );

Create a new object. Takes the arguments and use them to create a new entry at
the FreshBooks end. Once the object has been created a 'get' request is issued
to fetch the data back from freshboks and to populate the object.

=cut

sub create {
    my $self   = shift;
    my $args   = shift;
    my $method = $self->method_string('create');

    # add any additional argument to ourselves
    $self->$_( $args->{$_} ) for keys %$args;

    # create the arguments
    my %create_args = ();
    $create_args{$_} = $self->$_ for ( $self->field_names_rw );

    # remove arguments that have not been set (and so are undef)
    delete $create_args{$_}    #
        for grep { !defined $create_args{$_} }
        keys %create_args;

    my $res = $self->send_request(
        {   _method         => $method,
            $self->api_name => \%create_args,
        }
    );

    my $xpath  = '//response/' . $self->id_field;
    my $new_id = $res->findvalue($xpath);

    return $self->get( { $self->id_field => $new_id } );
}

=head2 update

  my $object = $object->update();

Update the object, saving any changes that have been made since the get.

=cut

sub update {
    my $self   = shift;
    my $method = $self->method_string('update');

    my %args = ();
    $args{$_} = $self->$_ for ( $self->field_names_rw, $self->id_field );

    my $res = $self->send_request(
        {   _method         => $method,
            $self->api_name => \%args,
        }
    );

    return $self;
}

=head2 get

  my $object = $self->get( \%args );

Fetches the object using the FreshBooks API.

=cut

sub get {
    my $self   = shift;
    my $args   = shift;
    my $method = $self->method_string('get');

    my $res = $self->send_request(
        {   _method => $method,
            %$args,
        }
    );

    return $self->_fill_in_from_node($res);
}

sub _fill_in_from_node {
    my $self    = shift;
    my $in_node = shift;

    # parse it as a new node so that the matching is more reliable
    my $parser = XML::LibXML->new();
    my $node   = $parser->parse_string( $in_node->toString );

    # cleanup all the keys
    delete $self->{$_}    #
        for grep { !m/^_/ } keys %$self;

    my $fields_config = $self->fields;

    # copy across the new values provided
    foreach my $key ( grep { !m/^_/ } keys %$fields_config ) {

        my $xpath .= sprintf "//%s/%s", $self->node_name, $key;

        # check that this field is not a special one
        if ( my $made_of = $fields_config->{$key}{made_of} ) {

            my ($match) = $node->findnodes($xpath);

            if ( $fields_config->{$key}{presented_as} eq 'array' ) {

                my @new_objects =    #
                    map { $made_of->new_from_node($_) }    #
                    grep { $_->nodeType eq XML_ELEMENT_NODE }
                    $match->childNodes();

                $self->{$key} = \@new_objects;
            } else {
                $self->{$key}                              #
                    = $match                               #
                    ? $made_of->new_from_node($match)      #
                    : undef;
            }

        } else {
            my $val = $node->findvalue($xpath);
            $self->{$key} = $val;
        }
    }

    return $self;

}

=head2 list

  my $iterator = $self->list( $args );

Returns an iterator that represents the list fetched from the server. 
See L<Net::FreshBooks::API::Iterator> for details.

=cut

sub list {
    my $self = shift;
    my $args = shift || {};

    return Net::FreshBooks::API::Iterator->new(
        {   parent_object => $self,
            args          => $args,
        }
    );
}

=head2 delete

  my $result = $self->delete();

Delete the given object.

=cut

sub delete {
    my $self = shift;

    my $method   = $self->method_string('delete');
    my $id_field = $self->id_field;

    my $res = $self->send_request(
        {   _method   => $method,
            $id_field => $self->$id_field,
        }
    );

    return 1;
}

=head1 INTERNAL METHODS

=head2 send_request

  my $response_data = $self->send_request( $args );

Turn the args into xml, send it to FreshBooks, recieve back the XML and 
convert it back into a perl data structure.

=cut

sub send_request {
    my $self = shift;
    my $args = shift;

    my $fb     = $self->_fb;
    my $method = $args->{_method};

    $fb->log( debug => "Sending request for $method" );

    my $request_xml   = $self->parameters_to_request_xml($args);
    my $return_xml    = $self->send_xml_to_freshbooks($request_xml);
    my $response_node = $self->response_xml_to_node($return_xml);

    $fb->log( debug => "Received response for $method" );

    return $response_node;
}

=head2 method_string

  my $method_string = $self->method_string( 'action' );

Returns a method string for this class - something like 'client.action'.

=cut

sub method_string {
    my $self   = shift;
    my $action = shift;

    return $self->api_name . '.' . $action;
}

=head2 api_name

  my $api_name = $self->api_name(  );

Returns the name that should be used in the API for this class.

=cut

sub api_name {
    my $self = shift;
    my $name = ref($self) || $self;
    $name =~ s{^.*::}{};
    return lc $name;
}

=head2 node_name

  my $node_name = $self->node_name(  );

Returns the name that should be used in the XML nodes for this class. Normally
this is the same as the C<api_name> but can be overridden if needed.

=cut

sub node_name {
    my $self = shift;
    return $self->api_name;
}

=head2 id_field

  my $id_field = $self->id_field(  );

Returns theh id field for this class.

=cut

sub id_field {
    my $self = shift;
    return $self->api_name . "_id";
}

=head2 field_names

  my @names = $self->field_names();

Return the names of all the fields.

=cut

sub field_names {
    my $self = shift;
    return sort keys %{ $self->fields };
}

=head2 field_names_rw

  my @names = $self->field_names_rw();

Return the names of all the fields that are marked as read and write.

=cut

sub field_names_rw {
    my $self   = shift;
    my $fields = $self->fields;
    return sort
        grep { $fields->{$_}{mutable} }
        keys %$fields;
}

=head2 parameters_to_request_xml

  my $xml = $self->parameters_to_request_xml( \%parameters );

Takes the parameters given and turns them into the xml that should be sent to
the server. This has some smarts that works around the tedium of processing perl
datastructures -> XML. In particular any key starting with an underscore becomes
an attribute. Any key pointing to an array is wrapped so that it appears
correctly in the XML.

=cut

sub parameters_to_request_xml {
    my $self       = shift;
    my $parameters = clone(shift);

    my $dom = XML::LibXML::Document->new( '1.0', 'utf-8' );

    my $root = XML::LibXML::Element->new('request');
    $dom->setDocumentElement($root);

    $self->construct_element( $root, $parameters );

    return $dom->toString(1);
}

sub construct_element {
    my $self    = shift;
    my $element = shift;
    my $hashref = shift;

    foreach my $key ( sort keys %$hashref ) {

        my $val = $hashref->{$key};

        # keys starting with an underscore are attributes
        if ( my ($attr_key) = $key =~ m{ \A _ (.*) \z }x ) {
            $element->setAttribute( $attr_key, $val );
        }

        # scalar values are text nodes
        elsif ( ref $val eq '' ) {
            $element->appendTextChild( $key, $val );
        }

        # arrayrefs are groups of nested values
        elsif ( ref $val eq 'ARRAY' ) {

            my $singular_key = $plural_to_singular{$key}
                || die "couldnot convert '$key' to singular";

            my $wrapper = XML::LibXML::Element->new($key);
            $element->addChild($wrapper);

            foreach my $entry_val (@$val) {
                my $entry_node = XML::LibXML::Element->new($singular_key);
                $wrapper->addChild($entry_node);
                $self->construct_element( $entry_node, $entry_val );
            }
        } elsif ( ref $val eq 'HASH' ) {
            my $wrapper = XML::LibXML::Element->new($key);
            $element->addChild($wrapper);

            $self->construct_element( $wrapper, $val );

        }

    }
}

=head2 response_xml_to_node

  my $params = $self->response_xml_to_node( $xml );

Take XML from FB and turn it into a datastructure that is easier to work with.

=cut

sub response_xml_to_node {
    my $self = shift;
    my $xml = shift || die "No XML passed in";

    # get rid of any namespaces that will prevent simple xpath expressions
    $xml =~ s{ \s+ xmlns=\S+ }{}xg;

    my $parser = XML::LibXML->new();
    my $dom    = $parser->parse_string($xml);

    my $response        = $dom->documentElement();
    my $response_status = $response->getAttribute('status');

    if ( $response_status ne 'ok' ) {
        my @error_nodes = $response->findnodes('/error');
        my $error = join ', ', map { $_->textContent } @error_nodes;
        croak "FreshBooks server returned error: '$error'";
    }

    return $response;
}

# {   XML_ELEMENT_NODE       => 1,
#     XML_ATTRIBUTE_NODE     => 2,
#     XML_TEXT_NODE          => 3,
#     XML_CDATA_SECTION_NODE => 4,
#     XML_ENTITY_REF_NODE    => 5,
#     XML_ENTITY_NODE        => 6,
#     XML_PI_NODE            => 7,
#     XML_COMMENT_NODE       => 8,
#     XML_DOCUMENT_NODE      => 9,
#     XML_DOCUMENT_TYPE_NODE => 10,
#     XML_DOCUMENT_FRAG_NODE => 11,
#     XML_NOTATION_NODE      => 12,
#     XML_HTML_DOCUMENT_NODE => 13,
#     XML_DTD_NODE           => 14,
#     XML_ELEMENT_DECL       => 15,
#     XML_ATTRIBUTE_DECL     => 16,
#     XML_ENTITY_DECL        => 17,
#     XML_NAMESPACE_DECL     => 18,
#     XML_XINCLUDE_START     => 19,
#     XML_XINCLUDE_END       => 20,
# };

# sub deconstruct_element {
#     my $self    = shift;
#     my $element = shift;
#
#     # warn ">>>>>>>>>>>>>>>>>>>>";
#     #
#     # warn Dumper(
#     #     {   element       => $element->toString(1),
#     #         nodeName      => $element->nodeName,
#     #         nodeType      => $element->nodeType,
#     #         textContent   => $element->textContent,
#     #         hasChildNodes => $element->hasChildNodes,
#     #     }
#     # );
#
#     my @children = $element->childNodes;
#
#     if ( scalar @children == 1 && $children[0]->nodeType == XML_TEXT_NODE ) {
#         my $val = $children[0]->textContent || '';
#         $val =~ s{ \A \s* ( .*? ) \s* \z }{$1}xms;
#
#         # warn "value: '$val'";
#         # warn '-' x 30;
#
#         return $val;
#     }
#
#     my $hashref = {};
#
#
#     # not a simple text element - is this a wrapper?
#     if ( $plural_to_singular{ $element->nodeName } ) {
#
#
#         my @array = ();
#         foreach my $child (@children) {
#             next unless $child->nodeType == XML_ELEMENT_NODE;
#             push @array, $self->deconstruct_element($child);
#         }
#         $hashref->{ $element->nodeName } = \@array;
#     }
#
#     # not a wrapper - probably a content
#     else {
#
#         foreach my $child (@children) {
#             next unless $child->nodeType == XML_ELEMENT_NODE;
#             $hashref->{ $child->nodeName }
#                 = $self->deconstruct_element($child);
#         }
#
#     }
#
#     # get all the attributes and store them
#     foreach my $attr ( $element->attributes ) {
#         next unless $attr;
#         my $key = "_" . $attr->nodeName;
#         my $val = $attr->value;
#         $hashref->{$key} = $val;
#     }
#
#     # warn Dumper($hashref);
#     # warn "-" x 30;
#
#     return scalar keys %$hashref ? $hashref : undef;
# }

=head2 send_xml_to_freshbooks

  my $returned_xml = $self->send_xml_to_freshbooks( $xml_to_send );

Sends the xml to the FreshBooks API and returns the XML content returned. This
is the lowest part and is encapsulated here so that it can be easily overridden
for testing.

=cut

sub send_xml_to_freshbooks {
    my $self        = shift;
    my $xml_to_send = shift;
    my $fb          = $self->_fb;
    my $ua          = $fb->ua;

    # my $log         = $fb->log;

    my $request = HTTP::Request->new(
        'POST',              # method
        $fb->service_url,    # url
        undef,               # header
        $xml_to_send         # content
    );

    $fb->clog($request);

    my $response = $ua->request($request);

    $fb->clog($response);

    croak "FreshBooks request failed: " . $response->status_line
        unless $response->is_success;

    return $response->content;
}

1;
