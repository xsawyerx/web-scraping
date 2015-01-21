#!perl
# people assigned to my colleagues' projects
use strict;
use warnings;
use Web::Query;
use IO::Prompt::Tiny 'prompt';
use IO::All;
use AnyEvent;
use AnyEvent::HTTP;
use DDP;
use Acme::CPANAuthors;

local $| = 1;

my @authors = Acme::CPANAuthors->new('Booking')->id;
wq("http://rawgit.com/CPAN-PRC/resources/master/january.html")
    ->find('tbody > tr')
    ->each( sub {
        my $release = wq($_)->find('td > a')->map( sub { $_->text } );

        foreach my $id (@authors) {
            if ( $release->[2] eq $id || $release->[3] =~ /^$id/i ) {
                printf "%s was assigned with %s's %s distribution.\n",
                    $release->[0], $id, $release->[1];
            }
        }
    } );
