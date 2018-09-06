#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use utf8;
use open qw/:utf8 :std/;

use Encode;
use Encode::Locale;

use Pod::Usage;
use Getopt::Long;
use Sort::Naturally;
use File::Basename;
use File::Spec::Functions qw/:ALL/;
use Data::Dumper;


=head1 NAME

mkvmerge-folder - merges different sources of media into mkv file input set from different folders 	

=cut

#************************************************************#
#                       input arguments                      #
#************************************************************#
our $mkvmerge = 'mkvmerge';
our $cmd_prefix = '';
our $cmd_suffix = '';
#our $cmd_prefix = '--default-title "Voltron Legendary Defender"';
#our $cmd_suffix = '--track-order 0:3,0:2';

our $outdir = '/data-store/tmp/Voltron.Legendary.Defender';
our $indir = '/data-store/Torrents/Voltron.Legendary.Defender.S01-03.1080p.NF.WEBRip.DD5.1.x264-NTb';


our @input = 
(
	{
		in  => '*.mkv',
		#filter => '',  # additional regex filter
		
		#name => '^(.*)(?=\.([^.]+))', # $1 - name, $2 - ext
		name => '(^Voltron\.Legendary\.Defender\.S\d+E\d+\.(.*))(?=.1080).*',
		cmd => 'qq/--default-track -1:0 --title "$2" "$inpath"/',
		out => 'sprintf q/"%s"/, catdir($outdir, qq/$1.mkv/)',
	},
	
	{
		in  => '\[SUB\]\ Notabenoid/*.srt',
		cmd => 'qq/--default-track -1:0 --language -1:rus "$inpath"/'
	},

	
);

#************************************************************#
#                       implementation                       #
#************************************************************#
binmode(STDIN,  ":encoding(console_in)")  if -t STDIN;
binmode(STDOUT, ":encoding(console_out)") if -t STDOUT;
binmode(STDERR, ":encoding(console_out)") if -t STDERR;

sub readfolder;
sub create_commands;

@input = map readfolder, @input;
create_commands @input;

exit 0;

sub readfolder
{
	my $arg = shift || $_;	
	my $rgx = $arg->{filter} || '.*';
	my $in  = rel2abs($arg->{in}, $indir);
	my @files;
	
	# unqoute if quoted, add .* if $in is a folder
	$in = $1 if $in =~ /^"(.*)"$/;
	$in = encode('locale_fs', $in);
	$in = catfile($in, '*') if -d $in;
		
	@files = grep { /$rgx/ }
	         map  { decode('locale_fs', $_, Encode::FB_CROAK) }
			 grep { -f and not /Thumbs.db/i }
	         glob "\"$in\"";
	
	$arg->{files} = [nsort @files];
	return $arg;	
}

sub create_commands
{
	my @input = @_;
	my $len = $#{ $input[0]->{files} };

	for my $i (0..$len)
	{
		my ($name_pattern, $cmd_template, $out_template) = @{$input[0]}{qw/name cmd out/};
		
		my $inpath = $input[0]->{files}[$i];
		my $infile = basename $inpath;
		$infile =~ /$name_pattern/ if $name_pattern;
		
		my $outfile = eval $out_template;
		$outfile = catfile $outdir, $outfile;
		
		# mkvmerge 
		my $cmd = sprintf "-o %s %s", eval $out_template, eval $cmd_template;

		for my $arg (@input[1..$#input])
		{
			($name_pattern, $cmd_template) = @{$arg}{qw/name cmd/};
		
			$inpath = $arg->{files}[$i];
			$infile = basename $inpath;
			next if not $infile;
		
			$infile =~ /$name_pattern/ if $name_pattern;
			$cmd .= ' ' . eval $cmd_template;
		}
		
		$cmd = "$mkvmerge $cmd_prefix $cmd $cmd_suffix";
		my $sys_cmd = encode('locale_fs', $cmd);
		#system $sys_cmd;
		print $cmd, "\n";
	}
}

