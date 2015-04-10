#!perl
# People assigned to my projects
use strict;
use warnings;
use Web::Query;

local $| = 1;

wq('http://cpan-prc.org/january.html')
    ->find('tbody > tr')
    ->each( sub {
        my $release = $_->find('td > a')->map( sub { $_->text } );

        $release->[2] eq 'XSAWYERX' || $release->[3] =~ /^xsawyerx/
            or return;

        printf "%s was assigned with your %s distribution.\n",
            @{$release}[0,1];
    } );
