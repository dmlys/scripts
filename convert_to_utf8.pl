#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use autodie;
use open qw/:utf8 :std/;

use Encode qw/encode decode/;
use Encode::Locale;
use File::Find::Rule;

our @exts = qw<*.h *.hpp *.hqt *.cpp *.java>;
our $verbose = 0;



if (not @ARGV) { @ARGV = ('.') };
our $finder = File::Find::Rule->new;
$finder->file->name(@exts);

our @files = $finder->in(@ARGV); # search by file extensions

my ($fin, $fout);

for my $file (@files)
{
	open $fin, "<:bytes", $file;
	my $octets = do { local $/ = undef; <$fin> };
	close $fin;
	
	my $content;
	eval { $content = decode("UTF-8", $octets, Encode::FB_CROAK); };
	if (not $@)
	{
		print "conversion not required: \"$file\"\n" if $verbose;
		next;
	}
		
	print "converting cp1251 -> utf-8: \"$file\"\n";
	$content = decode("cp1251", $octets);
	
	open $fout, ">:encoding(UTF-8)", $file;
	print $fout $content;
	close $fout;
}
