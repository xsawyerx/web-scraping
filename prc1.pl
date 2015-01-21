#!perl
# People assigned to my projects
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

wq("http://rawgit.com/CPAN-PRC/resources/master/january.html")
    ->find('tbody > tr')
    ->each( sub {
        my $release = wq($_)->find('td > a')->map( sub { $_->text } );

        $release->[2] eq 'XSAWYERX' || $release->[3] =~ /^xsawyerx/
            or return;

        printf "%s was assigned with your %s distribution.\n",
            @{$release}[0,1];
    } );
