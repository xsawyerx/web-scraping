#!perl
# Get the data for a type from schema.org
use strict;
use warnings;
use Web::Query;
use IO::Prompt::Tiny 'prompt';
use IO::All;
use DDP;

local $| = 1;

my $entity = prompt( 'Entity:', 'Event' );
wq("http://schema.org/$entity")
    ->find('table.definition-table > tbody.supertype > tr')
    ->each( sub {
        my ( $idx, $elem ) = @_;
        my $property = wq($_)->find('th.prop-nam > code > a')->text;
        my @types    = map $_->text,
                       wq($_)->find('td.prop-ect > a')->each(sub{1});

        print "Property: $property\n";
        print "Types: ", join( ', ', @types ), "\n";
        print "\n";
    } );
