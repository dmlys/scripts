#!/usr/bin/perl
use File::Find::Rule;

@exts = qw<*.h *.hpp *.hqt *.cpp *.java>;
if (not @ARGV) { @ARGV = ('.') };

$finder = File::Find::Rule->new;
$finder->file->name(@exts);

@files = $finder->in(@ARGV); # search by file extensions

for $file (@files)
{
	# because we are removing some content, 
	# we can actually can try to edit in place, line by line
	# open file for input and output
	open $fin,  "<$file" or print STDERR "Can't open <$file: $!\n" and next;
	open $fout, "+<$file" or print STDERR "Can't open >$file: $!\n" and next;
	# rewind output for beginning
	seek $fout, 0, SEEK_SET;

	$prevIndent = "";
	while (<$fin>)
	{
		# if only spaces and comments
		if (/^[ \t\/]*[ \t]$/)
		{
			# make it same length as prev indent
			$_ = "$prevIndent\n" if length $_ > length $prevIndent;
			next;
		}
		
		# extract indent
		($prevIndent) = (/^([ \t\/]*[ \t])/);
		# delete trailing spaces and tabs
		s/[ \t]+$//;
	} continue {
		print $fout $_;
	}
	
	
	truncate $fout, tell $fout;
	close $fout;
	close $fin;
}
