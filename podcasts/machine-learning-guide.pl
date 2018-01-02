#!/usr/bin/perl
# This downloads all the podcasts of Machine Learning Guide
# Available at http://ocdevel.com/podcasts/machine-learning/
#
# (This uses regexes for now which is really bad. Baaaaad!)
#
# Run this with:
# ->  perl machine-learning-guide.pl
#
# The dependencies used here are in core, so you likely do not
# need to install anything.
#
# If you wish, you can still do so with the following command:
# ->  curl -kL cpanmin.us | perl - LWP::UserAgent HTML::Entities

use strict;
use warnings;
use constant { 'TIMEOUT' => 10 };
use LWP::UserAgent;
use HTML::Entities qw< decode_entities >;

local $| = 1;

my $ua = LWP::UserAgent->new();
$ua->timeout( TIMEOUT() );

my $res = $ua->get('http://machinelearningguide.libsyn.com/rss');
$res->is_success
    or die "Failed to access page: " . $res->status_line;

# Perl::Critic policy gets confused here...
## no critic qw(Variables::ProhibitPunctuationVars)
## no critic qw(RegularExpressions::ProhibitCaptureWithoutTest)

my @lines = split /\n/xms, $res->decoded_content;
my ( $collect, @item );
foreach my $line (@lines) {
    chomp $line;
    $line =~ s{ ( ^ \s* | \s* $ ) }{}xmsg;

    $line =~ qr{^ <item> $}xms
        and $collect = 1;

    $collect && $line =~ qr{^ <title> \s* (.+) </title> $}xms
        and push @item, $1;

    $collect && $line =~ qr{^ <link> \s* \Q<![CDATA[\E (.+) \Q]]>\E </link> $}xms
        and push @item, $1;

    if ( $collect && $line =~ qr{^ </item> $}xms ) {
        my $title = decode_entities( shift @item );
        my $url   = shift @item;

        # Cleanup
        $title =~ s{&}{and}xmsg;
        $title =~ s{/}{or}xmsg;

        my $filename = "$title.mp3";
        if ( -e $filename ) {
            print "$filename already exists, skipping.\n";
            next;
        }

        print "Fetching $filename... ";
        my $file_res = $ua->get(
            $url,
            ':content_file' => $filename,
        );

        if ( ! $file_res->is_success ) {
            print "Failed: @{[ $file_res->status_line ]}, skipping.\n";
            next;
        }

        print "Done!\n";
    }
}
