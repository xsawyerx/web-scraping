#!perl
use strict;
use warnings;
use IO::All;
use IO::All::LWP;
use Web::Query;

local $| = 1;

wq('http://podbay.fm/show/536258179')
    ->find('table.table-striped > tbody > tr')
    ->each( sub {
        my $title = $_->find('td > a')->first->text;
        print "Fetching episode: $title... ";

        my $filename = "$title.mp3";
        if ( -e $filename ) {
            print "already exists.\n";
            return;
        }

        my $episode_href = $_->find('td > a.btn')
                             ->first->attr('href');

        my $download_href = wq($episode_href)
                                ->find('div #download > a.btn')
                                ->attr('href');

        io($download_href) > io($filename);
        print "done.\n";
    } );
