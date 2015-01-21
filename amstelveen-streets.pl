#!perl
# a list of all the streets in Amstelveen,
# including their neighborhood and description (historical stuff)
use strict;
use warnings;
use Web::Query;
use IO::Prompt::Tiny 'prompt';
use AnyEvent;
use AnyEvent::HTTP;
use DDP;

local $| = 1;

my $url = 'http://www.amstelveenweb.com';
my $cv  = AE::cv;
my @streets;
wq("$url/straten")
    ->find('div#linkercol > p > a')
    ->each( sub {
        my $letter = $_->attr('href');

        print "Streets starting with $letter...\n";
        $cv->begin;
        http_get "$url/$letter", sub {
            my $body = shift;
            $cv->end;
            my $str_names = wq($body)->find('b > a.wijklink')
                                     ->map(sub{ $_->text });

            my $str_neigh = wq($body)->find('div.straattabelwijken > i')
                                     ->map(sub{ $_->text });

            my $str_descs = wq($body)->find('div.straattabelbeschrijving')
                                     ->map(sub { $_->text });

            push @streets, map +{
                name         => $str_names->[$_],
                neighborhood => $str_neigh->[$_],
                description  => $str_descs->[$_],
            }, 0 .. $#{$str_names};
        };
    } );

$cv->recv;

p @streets;
