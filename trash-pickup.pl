#!perl
# Scheduled recycling pickups
# The default (1182JR 1) is for Amstelveen city hall
use strict;
use warnings;
use IO::Prompt::Tiny 'prompt';
use Web::Query;

local $| = 1;

my $p_year;
my $post  = uc prompt( 'Post:',      '1182JR' );
my $house =    prompt( 'House no.:',        1 );

wq("http://www.mijnafvalwijzer.nl/nl/$post/$house/")
    ->find('div.ophaaldagen > div')
    ->each( sub {
        my ( $month, $year ) = split '-', $_->attr('id');

        printf "%s* %s:\n", $p_year++ ? '' : "Year: $year\n\n", ucfirst $month;

        wq($_)->find('div.column > p')->each( sub {
            my ( $day_name, $day_num ) = split ' ', $_->text;
            my $type = wq($_)->find('span.afvaldescr')->text;
            print "\t> $day_num (@{[ucfirst $day_name]}): $type\n";
        });

        print "\n";
    } );
