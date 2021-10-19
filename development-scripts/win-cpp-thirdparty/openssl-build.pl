use File::Spec::Functions qw/:ALL/;
use File::Path qw<make_path remove_tree>;

use File::Copy;
use File::Copy::Recursive qw/dircopy/;
use File::chdir;

use autodie qw/:all/;

$src_dir = '.';

$vcvars = 'vc142vars';
$vcver  = '142';
$openssl_ver = 'openssl-1.1.1l';
$config_opts = 'no-hw no-shared no-asm no-zlib';

%env_x86 = read_env("$vcvars x86");
%env_x64 = read_env("$vcvars x64");

build_platform('x64');
build_platform('x86');
exit;


sub build_one
{
	my ($target, $variant, $build_dir) = @_;
	my $src_dir = rel2abs($main::src_dir);
	
	my $suffix;
	{
		my $static = $variant =~ /static/ ? 's' : '';
		my $debug = $target =~ /debug/ ? "gd" : '';
		my $sgd = $static || $debug ? "-${static}${debug}" : '';
		$suffix = "mt$sgd";
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
			s/([\/-])MT(d?)/$1MD$2/ if $variant =~ /shared/;
			s/libssl.lib/openssl-ssl-$suffix.lib/;
			s/libcrypto.lib/openssl-crypto-$suffix.lib/;
			print;
		}
	}
	
	system 'nmake';
}

sub build_platform
{
	my $platform = shift;
	my $env_name = "env_$platform";
	my $ar_name = "$openssl_ver-vc$vcver-$platform.7z";
				
	my $path = "build\\$platform";
	make_path "$path\\include", "$path\\lib";
	remove_tree "$path\\include", "$path\\lib", {keep_root => 1};
	
	my $name;
	$name = 'WIN32' if $platform =~ /x86/;
	$name = 'WIN64A' if $platform =~ /x64/;
	
	my @conf = (
		["debug-VC-$name", 'shared', "$path\\debug"],
		["debug-VC-$name", 'static', "$path\\debug-srt"],
		[      "VC-$name", 'shared', "$path\\release"],
		[      "VC-$name", 'static', "$path\\release-srt"],
	);
	
	local %ENV = %{$env_name};
	for my $conf (@conf)
	{
		my $dir = $conf->[2];
		
		build_one (@$conf);
		copy $_, "$path\\lib" for glob "$dir\\*.lib";
	}	
	
	dircopy "$src_dir\\include\\openssl", "$path\\include\\openssl";
	copy $_, "$path\\include\\openssl" for glob "$path\\release\\include\\openssl\\*.h";
	
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
