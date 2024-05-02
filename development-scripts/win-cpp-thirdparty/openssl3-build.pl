use File::Spec::Functions qw/:ALL/;
use File::Path qw<make_path remove_tree>;

use File::Copy;
use File::Copy::Recursive qw/dircopy/;
use File::chdir;

use autodie qw/:all/;

$src_dir = '.';

$vcvars = 'vc142vars';
$vcver  = '142';
$openssl_ver = 'openssl-3.3.0';
$config_opts = 'no-shared no-module no-asm no-zlib';

%env_x86 = read_env("$vcvars x86");
%env_x64 = read_env("$vcvars x64");

build_platform('x64');
build_platform('x86');
exit;


sub build_one
{
	my ($target, $variant, $build_dir) = @_;
	my $src_dir = rel2abs($main::src_dir);
	
	my $debug;
	my $static;
	my $static_suffix;
	my $shared_suffix;
	my $suffix;
	{
		$debug  = $target  =~ /debug/ ? "gd" : '';
		$static = $variant =~ /static/ ? 's' : '';
		
		$static_suffix = $debug ? "mt-sgd" : "mt-s";
		$shared_suffix = $debug ? "mt-gd"  : "mt";
		
		my $sgd = $static || $debug ? "-${static}${debug}" : '';
		$suffix = $static ? $static_suffix : $shared_suffix;
	}
	
	make_path $build_dir;
	local $CWD = $build_dir;
	
	system "perl \"$src_dir\\Configure\" $target $config_opts";
	
	{
		local @ARGV = qw/makefile/;
		local $^I = ".bak";
		
		while (<>)
		{
			s/([\/-])\bZi\b/$1Z7/;
			#s/([\/-])MT(d?)/$1MD$2/ if $variant =~ /shared/;
			s/\blibssl\.lib\b/openssl-ssl-$suffix.lib/;
			s/\blibcrypto\.lib\b/openssl-crypto-$suffix.lib/;
			print;
		}
	}
	
	system "nmake";
	system "mklink /H openssl-ssl-$shared_suffix.lib      openssl-ssl-$static_suffix.lib";
	system "mklink /H openssl-crypto-$shared_suffix.lib   openssl-crypto-$static_suffix.lib";
}

sub build_platform
{
	my $platform = shift;
	my $env_name = "env_$platform";
	my $ar_name = "$openssl_ver-vc$vcver-$platform.7z";
				
	my $path = "build\\$platform";
	remove_tree  $path, {keep_root => 1};
	make_path   "$path\\include", "$path\\lib";
	#remove_tree "$path\\include", "$path\\lib", {keep_root => 1};
	
	my $name;
	$name = 'WIN32'  if $platform =~ /x86/;
	$name = 'WIN64A' if $platform =~ /x64/;
	
	my @conf = (
		["debug-VC-$name", 'static', "$path\\debug-srt"],
		[      "VC-$name", 'static', "$path\\release-srt"],
	);
	
	local %ENV = %{$env_name};
	for my $conf (@conf)
	{
		my $dir = $conf->[2];
		
		build_one (@$conf);
		copy $_, "$path\\lib" for glob "$dir\\*.lib";
	}	
	
	make_path "$path\\include\\openssl";
	copy $_, "$path\\include\\openssl" for glob "$src_dir\\include\\openssl\\*.h";
	copy $_, "$path\\include\\openssl" for glob "$path\\release-srt\\include\\openssl\\*.h";
	copy "$src_dir\\ms\\applink.c", "$path\\include\\openssl";
	
	{
		local $CWD = $path;
		system "7z a $ar_name include lib";
	}
		
	move "$path\\$ar_name", ".";
}

sub read_env
{
	my $cmd = join ' ', @_;
	
	return  map { chomp; split /=/, $_, 2 } 
	       grep { not /---/ .. /===/ } 
	       `\@echo --- && $cmd && \@echo === && set` or die "$!";
}
