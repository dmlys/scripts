#!/usr/bin/perl
use strict;
use warnings;

use utf8;
use open qw/:utf8 :std/;
use autodie qw/:all/;

use File::Basename;
use File::Spec::Functions qw/:ALL/;

use Encode;
use Encode::Locale;
use XML::LibXML;

use Pod::Usage;
use Getopt::Long;
use Data::Dumper;

sub ReadFiles
{
	my $file = shift;
	my @result;
	
	open my $fh, '<:raw', $file;
	my $doc = XML::LibXML->load_xml(IO => $fh);
	close $fh;
	
	my $xp = XML::LibXML::XPathContext->new($doc);
	$xp->registerNs('msbuild', 'http://schemas.microsoft.com/developer/msbuild/2003');
	
	for my $el (qw/ClInclude ClCompile QtMOCCompile Text Natvis/)
	{
		push @result, map { $_->nodeValue } $xp->findnodes("/msbuild:Project/msbuild:ItemGroup/msbuild:$el/\@Include");
	}
	
	return @result;
}

for my $proj_file (@ARGV)
{
	my $proj = canonpath $proj_file;
	my $dir = dirname $proj;

	for my $file (ReadFiles $proj)
	{
		$file = rel2abs $file, $dir;
		print "$file\n" unless -e $file;
	}
}
