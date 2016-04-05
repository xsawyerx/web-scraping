#!perl
use strict;
use warnings;
use IO::All;
use IO::All::LWP;
use Web::Query;

local $| = 1;

my @months         = qw< jan feb apr may jun jul aug sep oct nov dec >;
my $main_url       = 'http://www.thisamericanlife.org/';
my $episode        = wq($main_url)->find('.this-week > .content');
my $episode_title  = $episode->find('h3 > a')->text =~ s/^\d+\:\s+//r;
my $episode_number = $episode->find('h3 > a')->text =~ s/^(\d+).*$/$1/r;
my $episode_url    = $episode->find('.actions > .download > a')
                             ->first->attr('href');

my $episode_date = do {
    my $date_str = $episode->find('.date')->text
        or die "Can't get date\n";

    $date_str =~ s/,//g;

    my ( $month_name, $day, $year ) = split /\s+/, $date_str;
    my $month = 1;

    foreach my $cur_month (@months) {
        $cur_month eq lc $month_name and last;
        $month++;

        # reached end
        $cur_month eq lc $months[-1]
            and die "Can't find month $month_name\n";
    }

    sprintf '%d-%02d-%02d', $year, $month, $day;
};

my $filename = "$episode_number - $episode_title ($episode_date).mp3";

if ( -e $filename ) {
    print "Episode $episode_number already downloaded.\n";
    exit;
}

print ">> $filename\n";
io($episode_url) > io($filename);
print "Done!\n";
