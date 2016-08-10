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
use Data::Dumper;

use Sort::Naturally;
use File::Basename;
use File::Spec::Functions qw/:ALL/;


=head1 NAME

mkvmerge-folder - merges different sources of media into mkv file input set from different folders 	

=cut

#************************************************************#
#                       input arguments                      #
#************************************************************#
our $mkvmerge = 'D:\\Others\\mkvtoolnix\\mkvmerge.exe';
our $outdir = 'out';
our $indir = 'D:\\work\\mkvmerge\\movie';
our $deftitle = 'movie';
#our $track_order = "0:3,0:2";

our @input = 
(
	{
		in  => '*.mkv',
		# filter => '',  additional regex filter
		# lan => '2:rus 3:eng 4:eng',
		
		name  => '',
		subst => 'qq{$1.mkv}',
		title => 'qq{$2}'
		
		#other => '--default-track -1:0'
	},
	
	{
		in  => 'Subs\\*.srt',
		lan => 'rus',
		#other => '--default-track -1:0'
	},
	
);

#************************************************************#
#                       implementation                       #
#************************************************************#
binmode(STDIN,  ":encoding(console_in)");  #if -t STDIN;
binmode(STDOUT, ":encoding(console_out)"); #if -t STDOUT;
binmode(STDERR, ":encoding(console_out)"); #if -t STDERR;

sub readfolder;
sub create_commands;
sub create_language;

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
	$in .= '\\*' if -d $in;
		
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
	my $len        = $#{ $input[0]->{files} };
	my $rgx_expr   = $input[0]->{name} || '^.*(?=\.[^.]+)';
	my $subst_expr = $input[0]->{subst} || '&?.mkv';
	my $title_expr = $input[0]->{title};
	our $track_order;
		

	for my $i (0..$len)
	{
		my $infile = basename $input[0]->{files}[$i];
		$infile =~ /$rgx_expr/;
		
		my $outfile = eval $subst_expr;
		$outfile = catfile $outdir, $outfile;
		
		my $title = defined($title_expr) ? eval $title_expr : $deftitle;
		my $cmd = "$mkvmerge -o \"$outfile\" --title \"$title\"";

		for my $arg (@input)
		{
			my $in = $arg->{files}[$i];
			next if not $in;
						
			my $other = $arg->{other} // '';
			my $lan = create_language $arg->{lan};
			$cmd .= " $other $lan \"$in\"";
		}
		
		$cmd .= " --track-order $track_order" if $track_order;
		my $sys_cmd = encode('locale_fs', $cmd);
		#system $sys_cmd;
		print $cmd, "\n";
	}
}

sub create_language
{
	local $_ = shift || $_;
	return "" if not $_;
	
	$_ = join ' ', @$_ if ref($_) eq 'ARRAY';
	
	my @lans = split /\s/, $_;
	my $n = 0;
	my $res = '';
	
	for (@lans)
	{
		$res .= " $_",              next  if /^\s*--/;
		$res .= " --language $_",   next  if /\d+:.*/;
		$res .= " --language $n:$_"; $n++;
	}
		
	return $res;
}

