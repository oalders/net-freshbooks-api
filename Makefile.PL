use ExtUtils::MakeMaker;
use strict;
use warnings;

WriteMakefile(
    NAME         => 'Net::FreshBooks::API',
    VERSION_FROM => 'lib/Net/FreshBooks/API.pm',
    LICENSE      => 'perl',

    PREREQ_PM => {
        'Carp'                  => 0,
        'Class::Accessor::Fast' => 0,
        'Clone'                 => 0,
        'Data::Dump'            => 0,
        'Data::Dumper'          => 0,
        'Lingua::EN::Inflect'   => 0,
        'LWP::UserAgent'        => 0,
        'URI'                   => 0,
        'XML::LibXML'           => 0,

        # Testing
        'File::Slurp'          => 0,
        'Sub::Override'        => 0,
        'Test::More'           => 0,
        'Test::WWW::Mechanize' => 0,
        'Test::XML'            => 0,
    },
);

