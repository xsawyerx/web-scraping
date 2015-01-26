#!perl
use strict;
use warnings;
use IO::All;
use IO::All::LWP;
use Web::Query;
use Lingua::EN::Words2Nums;

local $| = 1;

wq('http://thisiscriminal.com')
    ->find('main#main > article.post')
    ->each( sub {
        my ($count, $post) = @_;
        my $hdr   = $post->find('header.entry-header > h1 > a');
        my $title = $hdr->text =~ s/\N{RIGHT SINGLE QUOTATION MARK}/'/rg;
        my $link  = $hdr->attr('href');

        # skip live show
        $title eq 'CRIMINAL LIVE SHOW' and return;

        my $filename =
            $title =~ s/^EPISODE ([^:]+)\:(.+)$/words2nums($1) . " -$2.mp3"/re;

        print "[@{[$count+1]}]: Fetching episode: $title... ";

        if ( -e $filename ) {
            print "already exists.\n";
            return;
        }

        my $episode_link = $post->find('div.entry-content')
                                ->find('iframe')->attr('src');

        my $widget_js_link = $episode_link->find('script')->first->attr('src');

        my $js           < io("https://w.soundcloud.com$widget_js_link");
        my ($client_id)  = $js =~ /production\:"([0-9a-f]+)"/;
        my ($episode_id) = $episode_link =~ /tracks(?:\/|%2F)([0-9]+)/;

        io(
            "https://api.soundcloud.com/tracks/$episode_id/download"
          . "?client_id=$client_id"
        ) > io($filename);

        print "done\n";
    } );
