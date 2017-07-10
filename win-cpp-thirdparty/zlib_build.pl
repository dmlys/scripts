use autodie;
use File::Copy;
use File::Path qw<make_path>;

our $ver = '1.2.8';
our $vcver = 'vc14.1';
our $name = 'zlib';
our $arname86 = "$name-$ver-$vcver-x86.zip";
our $arname64 = "$name-$ver-$vcver-x64.zip";

sub Exec;
sub build_one;

sub MD
{ 
	s/^STATICLIB\s+=\s+(.*)$/STATICLIB = zlib-mt.lib/; 
	s/^(CFLAGS\s+=)(.*)-Zi(.*)$/$1$2-Z7$3/;
	$_;
}

sub MT 
{
	s/^STATICLIB\s+=\s+(.*)$/STATICLIB = zlib-mt-s.lib/;
	s/^(CFLAGS\s+=)(.*)-MD(.*)$/$1$2-MT$3/;
	s/^(CFLAGS\s+=)(.*)-Zi(.*)$/$1$2-Z7$3/;
	$_; 
}

sub MDD
{
	s/^STATICLIB\s+=\s+(.*)$/STATICLIB = zlib-mt-gd.lib/; 
	s/^(CFLAGS\s+=)(.*)-MD(.*)$/$1$2-MDd$3/;
	s/^(CFLAGS\s+=)(.*)-Zi(.*)$/$1$2-Z7$3/;
	$_;
}

sub MTD
{
	s/^STATICLIB\s+=\s+(.*)$/STATICLIB = zlib-mt-sgd.lib/;
	s/^(CFLAGS\s+=)(.*)-MD(.*)$/$1$2-MTd$3/;
	s/^(CFLAGS\s+=)(.*)-Zi(.*)$/$1$2-Z7$3/;
	$_;
}

system 'rd release-x86 release-x64  /q/s';

PrepareMakefile('win32/Makefile.msc', 'win32/MakefileShared.msc', \&MD);
PrepareMakefile('win32/Makefile.msc', 'win32/MakefileStatic.msc', \&MT);
PrepareMakefile('win32/Makefile.msc', 'win32/MakefileSharedDebug.msc', \&MDD);
PrepareMakefile('win32/Makefile.msc', 'win32/MakefileStaticDebug.msc', \&MTD);

build_one "${vcver}vars x86", 'release-x86';
build_one "${vcver}vars x64", 'release-x64';

system "pushd release-x86 & 7z a -tzip $arname86 & popd";
system "pushd release-x64 & 7z a -tzip $arname64 & popd";

move "release-x86/$arname86", '.';
move "release-x64/$arname64", '.';

sub build_one
{
	my $vars = shift;
	my $dest = shift;
	
	make_path "$dest/lib";	
	Exec $vars, 'nmake -f win32/MakefileShared.msc clean zlib-mt.lib';
	copy 'zlib-mt.lib', "$dest/lib/zlib-mt.lib";

	Exec $vars, 'nmake -f win32/MakefileStatic.msc clean zlib-mt-s.lib';
	copy 'zlib-mt-s.lib', "$dest/lib/zlib-mt-s.lib";
	
	Exec $vars, 'nmake -f win32/MakefileSharedDebug.msc clean zlib-mt-gd.lib';
	copy 'zlib-mt-gd.lib', "$dest/lib/zlib-mt-gd.lib";
	
	Exec $vars, 'nmake -f win32/MakefileStaticDebug.msc clean zlib-mt-sgd.lib';
	copy 'zlib-mt-sgd.lib', "$dest/lib/zlib-mt-sgd.lib";

	Exec $vars, 'nmake -f win32/MakefileStaticDebug.msc clean';
	system 'del *lib';
	
	make_path "$dest/include";
	copy 'zconf.h', "$dest/include/zconf.h";
	copy 'zlib.h', "$dest/include/zlib.h";	
}

sub PrepareMakefile
{
	my $src = shift;
	my $dest = shift;
	my $func = shift;
	
	open my $sf, "<$src";
	open my $df, ">$dest";
	
	while (<$sf>)
	{
		$_ = $func->($_);
		print $df $_;
	}
	
	close $df;
	close $sf;
}

sub Exec
{
	my $vars = shift;
	my $command = shift;
	
	my $cmd = <<"END";
call $vars & $command
END
	
	system $cmd;
}
