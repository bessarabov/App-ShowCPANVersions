# Some statistics about CPAN version

This small projcect is a result of a discussion on QH: http://questhub.io/realm/perl/quest/51d303b4ecc7889b40000025

It shows some statistics about CPAN version.

## 2013-07-17 results

The output of this scrip on 2013-07-17 is:

    $ time perl bin/show_cpan_versions.pl
    ^\d+\.\d{2}$                  1774       59.13
    ^\d+\.\d{3}$                   236        7.87
    ^\d+\.\d{1}$                   206        6.87
    other                          188        6.27
    ^\d+\.\d+\.\d+$                179        5.97
    ^\d+\.\d{6}$                   176        5.87
    ^\d+\.\d{4}$                    92        3.07
    ^v\d+\.\d+\.\d+$                53        1.77
    ^\d+\.\d{5}$                    50        1.67
    ^\d+\.\d+$                      46        1.53
    #END

    real    0m2.142s
    user    0m0.220s
    sys     0m0.010s

And the full log is at https://gist.github.com/bessarabov/6019549
