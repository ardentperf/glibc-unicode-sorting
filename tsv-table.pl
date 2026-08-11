#!/usr/bin/env perl

# Generate a GitHub-Markdown-compatible HTML table from checksum TSV data.
# Usage: tsv-table.pl ENGINE [ARCHITECTURE] [TSV_FILE]
#        tsv-table.pl rhel ENGINE [ARCHITECTURE] [TSV_FILE]

use strict;
use warnings;
binmode STDOUT, ':encoding(UTF-8)';
my ($dataset, $engine, $architecture, $file) = @ARGV;
if ($dataset eq 'rhel') {
    $file //= 'testdata/redhat-md5sums.tsv';
} else {
    ($file, $architecture) = ($architecture, $engine) if defined $file;
    ($engine, $architecture, $file) = ($dataset, $engine, $architecture);
    $file //= 'testdata/debian-md5sums.tsv';
}
$architecture //= 'x86_64';
die "Usage: $0 ENGINE [ARCHITECTURE] [TSV_FILE]\n       $0 rhel ENGINE [ARCHITECTURE] [TSV_FILE]\n"
    unless defined $engine;
die "Engine must be glibc or icu\n" unless $engine eq 'glibc' || $engine eq 'icu';
open my $fh, '<', $file or die "Cannot open $file: $!\n";

my (%cell, %language, %debian, %runtime_version);
while (my $line = <$fh>) {
    chomp $line;
    next if $line eq '' || $line =~ /^\s*#/;
    my @f = split /\t/, $line, -1;
    die "Malformed TSV line: $line\n" unless @f >= 7;

    my ($version, $arch, $lang, $row_engine, $checksum, undef, $sort_ms) = @f;
    next unless $arch eq $architecture && $row_engine eq $engine;
    next unless $checksum ne '' && $sort_ms ne '' && $sort_ms ne 'unknown';

    $language{$lang} = 1;
    $debian{$version} = 1 if $version eq 'sid' || $version =~ /^\d+$/;
    $runtime_version{$version} = $engine eq 'icu' ? $f[8] : $f[7];
    my $minutes = sprintf '%.1f', $sort_ms / 60000;
    $minutes =~ s/0+$//;
    $minutes =~ s/\.$//;
    my $suffix = substr($checksum, -6);
    $cell{$lang}{$version} = {
        text => '<img src="https://img.shields.io/badge/-'
            . html_escape($suffix) . '-' . $suffix
            . '"><br>*' . $minutes . '&nbsp;min*',
    };
}
close $fh;

my @versions = sort {
    $a eq 'sid' ? -1 : $b eq 'sid' ? 1 : $b <=> $a
} keys %debian;
my $special_language = $engine eq 'glibc' ? 'C' : 'root';
my @language_order = ($special_language, qw(de en fr ru ar es ja ko zh));
my %language_rank = map { $language_order[$_] => $_ } 0 .. $#language_order;
my @languages = sort {
    ($language_rank{$a} // 1000) <=> ($language_rank{$b} // 1000)
        || $a cmp $b
} keys %language;

sub html_escape {
    my ($value) = @_;
    $value =~ s/&/&amp;/g;
    $value =~ s/</&lt;/g;
    $value =~ s/>/&gt;/g;
    return $value;
}

print '| |';
for my $version (@versions) {
    my $runtime = $runtime_version{$version} // '';
    my $platform = $dataset eq 'rhel' ? 'RHEL' : 'Debian';
    print ' ' . $platform . '&nbsp;' . html_escape($version) . ':';
    print '<br>*' . html_escape($runtime) . '*' if $runtime ne '';
    print '|';
}
print "\n|---" . ('|---' x scalar @versions) . "|\n";
for my $lang (@languages) {
    my $display_lang = $engine eq 'glibc' && $lang eq 'C'
        ? 'C' . chr(0x2060) . '.' . chr(0x2060)
            . 'UTF' . chr(0x2060) . '-' . chr(0x2060) . '8'
        : $lang;
    print '| **' . html_escape($display_lang) . '**';
    for my $version (@versions) {
        my $value = $cell{$lang}{$version};
        if ($value) {
            print '| ' . $value->{text};
        } else {
            print '| ';
        }
    }
    print "|\n";
}
