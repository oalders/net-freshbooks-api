#!perl -w

use strict;
use warnings;

use Find::Lib '.';

use OAuthDemo;

OAuthDemo->new_with_options->run;
