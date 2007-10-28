#!/usr/bin/perl

use strict;
use Data::Dumper;
use Encode;
use Getopt::Long;
use HTML::Entities;

our %OPTS = (
    indir=>'.',
);
GetOptions(\%OPTS,
    'indir=s',
);

# list up target files.
my $dir = $OPTS{indir};
$dir =~ s/[\/\\]$//;
opendir DIR, $dir;
my @targets = map { "$dir/$_" } grep { m/\...x$/ } readdir DIR;
close DIR;

# scan all files and get info.
my @infos;
foreach my $target (@targets) {
    my $info = &get_info($target);
    next if not defined $info;
    push @infos, $info;
}
@infos = sort { $a->{_name_} cmp $b->{_name_} } @infos;

# output as HTML table.
my $OUT = \*STDOUT;
#binmode STDOUT, ":encoding(utf-8)";
print $OUT "<table border=\"1\">\n";
print $OUT "<tr><th>Name</th><th>Status</th><th>Translator</th><th>Description</th></tr>\n";
foreach my $info (@infos) {
    my $n = &html_encode($info->{_name_});
    my $s = &html_encode($info->{STATUS});
    my $t = $info->{TRANSLATOR};
    my $c = &html_encode($info->{COMMENT});
    $t = $t->[-1] if ref($t) eq 'ARRAY';
    $t =~ s/\s*<[^@]*@[^>]*>//;
    $t = &html_encode($t);
    print $OUT "<tr><td>$n</td><td>$s</td><td>$t</td><td>$c</td></tr>\n";
}
print $OUT "</table>\n";

sub html_encode
{
    return encode_entities(shift, '<>&"\'');
}

sub get_info
{
    my $target = shift;
    my $info = undef;
    open IN, $target or return undef;
    #binmode IN, ":encoding(utf-8)";
    while (my $line = <IN>) {
	chomp $line;
	if ($line =~ m/^([^:]+):\s*(.*)$/) {
	    my ($key, $value) = ($1, $2);
	    if (not exists $info->{$key}) {
		$info->{$key} = $value;
	    } else {
		if (ref($info->{$key}) ne 'ARRAY') {
		    $info->{$key} = [$info->{$key}];
		}
		push @{$info->{$key}}, $value;
	    }
	} elsif (length($line) == 0) {
	    last;
	}
    }
    my $name = $target;
    $name =~ s/^.*[\/\\]//;
    $name =~ s/\...x$//;
    $info->{_name_} = $name;
    close IN;
    return $info;
}
