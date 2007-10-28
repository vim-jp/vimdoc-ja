#!/usr/bin/perl

use File::Basename;
use File::Path;

our $OUTDIR = undef;
our $OUTEXT = 'out';
our @INFILES = ();
our $MOD_SCRIPT = (stat($0))[9];
our $MKDIR = 0;
our $VERBOSE = 0;

for (my $i = 0; $i < @ARGV; ++$i)
{
    my $curr = $ARGV[$i];
    my $has_next = $i + 1 < @ARGV;
    if ($curr =~ m/^-/)
    {
	if ($curr =~ m/^-v(?:=(\d+))?$/)
	{
	    if (defined $1)
	    {
		$VERBOSE = $1 + 0;
	    }
	    else
	    {
		++$VERBOSE;
	    }
	}
	elsif ($curr eq '-d' and $has_next)
	{
	    $OUTDIR = $ARGV[++$i];
	}
	elsif ($curr eq '-e' and $has_next)
	{
	    $OUTEXT = $ARGV[++$i];
	}
	elsif ($curr eq '-p')
	{
	    $MKDIR = 1;
	}
	else
	{
	    print STDERR "Unknown option: $curr\n";
	}
    }
    else
    {
	push @INFILES, $curr;
    }
}

for my $infile (@INFILES)
{
    if (not -e $infile)
    {
	print STDERR "Skip unexist: $infile\n";
	next;
    }
    my $outfile = &get_outfile($infile);
    if ($outfile eq $infile)
    {
	print STDERR "Skip overwrite: $infile\n";
	next;
    }
    if (-e $outfile)
    {
	my $mod_out = (stat($outfile))[9];
	my $mod_in = (stat($infile))[9];
	if ($mod_out >= $mod_in and $mod_out >= $MOD_SCRIPT)
	{
	    print STDERR "Skip newer: $infile\n" if $VERBOSE >= 2; 
	    next;
	}
    }
    if ($MKDIR)
    {
	my $outdir = dirname($outfile);
	mkpath([$outdir], $VERBOSE, 0755) if not -e $outdir;
    }
    if (not open(OUT, ">$outfile"))
    {
	print STDERR "Skip can't write: $outfile\n";
	next;
    }
    open IN, $infile;
    print STDERR "Updated: $infile\n" if $VERBOSE >= 1;
    &filter_file($infile, $outfile, \*IN, \*OUT);
    close IN;
    close OUT;
}

sub get_outfile
{
    my $infile = shift;
    my ($name, $path, $ext) = fileparse($infile, qr{\..*$});
    $path = $OUTDIR if defined $OUTDIR;
    $path =~ s/[\\\/]+$//;
    $ext = $OUTEXT;
    return "$path/$name.$ext";
}

sub filter_file
{
    my $infile = shift;
    my $outfile = shift;
    my $IN = shift;
    my $OUT = shift;
    binmode $IN;
    binmode $OUT;
    while (<$IN>)
    {
	$_ =~ s/\s+$//;
	last if length($_) == 0;
	# Parse as header.
    }
    while (<$IN>)
    {
	$_ =~ s/\s+$//;
	print $OUT "$_\n";
    }
}
