#!/usr/bin/perl

=encoding UTF-8
=cut

=head1 DESCRIPTION

=cut

# common modules
use strict;
use warnings FATAL => 'all';
use 5.010;
use utf8;
use open qw(:std :utf8);

use DDP;
use Carp;
use lib::abs qw(
    ./lib
);

use MetaCPAN::API;
use File::Slurp;
use Perl6::Form;

# global vars
my $true = 1;
my $false = '';

# subs

# main
sub main {

    my $mcpan  = MetaCPAN::API->new();

    # The order of elements in $types matter
    my $types = [
        {
            name => 'undef',
            check => sub { not defined $_[0] },
        },
        {
            regexp => qr/^\d+\.\d+\.\d+$/,
        },
        {
            regexp => qr/^v\d+\.\d+\.\d+$/,
        },
        {
            regexp => qr/^\d+\.\d{6}$/,
        },
        {
            regexp => qr/^\d+\.\d{5}$/,
        },
        {
            regexp => qr/^\d+\.\d{4}$/,
        },
        {
            regexp => qr/^\d+\.\d{3}$/,
        },
        {
            regexp => qr/^\d+\.\d{2}$/,
        },
        {
            regexp => qr/^\d+\.\d{1}$/,
        },
        {
            regexp => qr/^\d+\.\d+$/,
        },
        {
            name => 'other',
            check => sub {$true},
        }
    ];

    foreach my $t (@{$types}) {

        # fixing name
        if (not exists $t->{name}) {
            if (defined $t->{regexp}) {
                my $scalar = $t->{regexp} . "";
                $scalar =~ /^\(\?-xism:(.*)\)$/;
                $t->{name} = $1;
            } else {
                croak 'Incorrect data';
            }
        }

        # fixing check
        if (not exists $t->{check}) {
            if (defined $t->{regexp}) {
                $t->{check} = sub {
                    $_[0] =~ $t->{regexp};
                };
            } else {
                croak 'Incorrect data';
            }
        }

    }

    my $limit = 3_000;

    my $dists = $mcpan->post(
        "release/_search?size=$limit",
        {
            query  => { match_all => {} },
            fields => [qw(
                release.date
                release.distribution
                release.name
                release.version
                release.module
            )],
       },
    );

    my $results = {};
    my $all_count = 0;

    foreach my $dist (@{$dists->{hits}->{hits}}) {
        my $version = $dist->{fields}->{version};
        my $name = $dist->{fields}->{name};

        my $type;
        CHECK_TYPES:
        foreach my $t (@{$types}) {
            my $check_result = $t->{check}->($version);
            if ($check_result) {
                $type = $t->{name};
                last CHECK_TYPES;
            }
        }
        $results->{$type}->{count}++;
        push @{$results->{$type}->{dists}}, "$name => $version";
        $all_count++;
    }

    my $data;

    my $format = "{<<<<<<<<<<<<<<<<<<<<} {>>>>>>>>>} {>>>>>>>>>}";
    foreach my $type (sort { $results->{$b}->{count} <=> $results->{$a}->{count} } keys %{$results}) {

        my $percent = sprintf("%0.2f", ( $results->{$type}->{count} * 100) / $all_count );

        print form $format,
            $type,
            $results->{$type}->{count},
            $percent
            ;
        $data .= "## $type Count: "
            . $results->{$type}->{count}
            . " Percent: "
            . $percent
            . "\n\n"
            . join("\n", @{$results->{$type}->{dists}})
            . "\n\n"
            ;
    }

    write_file("data.log", $data);

    say '#END';
}

main();
__END__
