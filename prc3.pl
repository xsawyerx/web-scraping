#!perl
# people assigned to my colleagues' projects, sorted by colleague
use strict;
use warnings;
use Web::Query;
use IO::Prompt::Tiny 'prompt';
use IO::All;
use AnyEvent;
use AnyEvent::HTTP;
use DDP;
use Acme::CPANAuthors;
use Encode 'decode_utf8', 'encode_utf8';

local $| = 1;

my $authors = Acme::CPANAuthors->new('Booking');
my @authors = $authors->id;
my %assignments;
wq("http://rawgit.com/CPAN-PRC/resources/master/january.html")
    ->find('tbody > tr')
    ->each( sub {
        my $release = wq($_)->find('td > a')->map( sub { $_->text } );

        foreach my $id (@authors) {
            if ( $release->[2] eq $id || $release->[3] =~ /^$id/i ) {
                push @{ $assignments{$id} }, $release;
            }
        }
    } );

foreach my $id ( keys %assignments ) {
    my $releases = $assignments{$id};
    print encode_utf8($authors->name($id)), ":\n";
    printf "\t%s assigned with %s\n", decode_utf8($_->[0]), decode_utf8($_->[1])
        for @{$releases};
}
