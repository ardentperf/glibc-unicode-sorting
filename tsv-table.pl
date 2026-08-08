#!/usr/bin/env perl

# Generate a GitHub-Markdown-compatible HTML table from md5sums.tsv.
# Usage: tsv-table.pl ENGINE [ARCHITECTURE] [TSV_FILE]

use strict;
use warnings;
my ($engine, $architecture, $file) = @ARGV;
$architecture //= 'x86_64';
die "Usage: $0 ENGINE [ARCHITECTURE] [TSV_FILE]\n" unless defined $engine;
die "Engine must be glibc or icu\n" unless $engine eq 'glibc' || $engine eq 'icu';

$file //= 'testdata/md5sums.tsv';
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
        text => '<img alt="' . html_escape($suffix) . '" src="https://img.shields.io/badge/-'
            . html_escape($suffix) . '-' . $suffix
            . '?style=flat"><br><i>' . $minutes . '&nbsp;min</i>',
    };
}
close $fh;

my @versions = sort {
    $a eq 'sid' ? -1 : $b eq 'sid' ? 1 : $b <=> $a
} keys %debian;
my $special_language = $engine eq 'glibc' ? 'C' : 'root';
my @language_order = ($special_language, qw(de en fr ar ru es ja ko zh));
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

print "<table>\n<thead>\n<tr><th></th>";
for my $version (@versions) {
    my $runtime = $runtime_version{$version} // '';
    print "<th>Debian&nbsp;" . html_escape($version) . ":";
    print "<br><i>" . html_escape($runtime) . "</i>" if $runtime ne '';
    print "</th>";
}
print "</tr>\n</thead>\n<tbody>\n";
for my $lang (@languages) {
    print "<tr><th>" . html_escape($lang) . "</th>";
    for my $version (@versions) {
        my $value = $cell{$lang}{$version};
        if ($value) {
            print '<td>' . $value->{text} . '</td>';
        } else {
            print '<td></td>';
        }
    }
    print "</tr>\n";
}
print "</tbody>\n</table>\n";
