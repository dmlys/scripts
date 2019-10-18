$ver = "1.1.1"

function deploy([string]$buildDir, [string]$includeDir, [string]$targetDir)
{
	ri $targetDir -force -recurse | Out-Null
	mkdir "$targetDir/include"
	mkdir "$targetDir/lib"
	mkdir "$targetDir/bin"

	#includes
	robocopy "$includeDir/log4cplus" "$targetDir/include/log4cplus" /S
	
	#libs and static pdb
	robocopy "$buildDir/bin.Debug" "$targetDir/lib"             *.lib log4cplusS*.pdb
	robocopy "$buildDir/bin.Debug_Unicode" "$targetDir/lib"     *.lib log4cplusS*.pdb
	robocopy "$buildDir/bin.Release" "$targetDir/lib"           *.lib log4cplusS*.pdb
	robocopy "$buildDir/bin.Release_Unicode" "$targetDir/lib"   *.lib log4cplusS*.pdb
	
	#dll and nonstatic pdb
	robocopy "$buildDir/bin.Debug" "$targetDir/bin"             *.dll *.pdb /XF log4cplusS*.pdb *.c.pdb
	robocopy "$buildDir/bin.Debug_Unicode" "$targetDir/bin"     *.dll *.pdb /XF log4cplusS*.pdb *.c.pdb
	robocopy "$buildDir/bin.Release" "$targetDir/bin"           *.dll *.pdb /XF log4cplusS*.pdb *.c.pdb
	robocopy "$buildDir/bin.Release_Unicode" "$targetDir/bin"   *.dll *.pdb /XF log4cplusS*.pdb	 *.c.pdb
	
	if ($targetDir -like '*x64*') { $aname = "log4cplus-$ver-vc12-x64.7z" }
	else                          { $aname = "log4cplus-$ver-vc12.7z" }
	
	pushd $targetDir
	& 7z a $aname .\
	popd
	
	move "$targetDir\$aname" . -force
}

#Win32
deploy "msvc10/Win32" "include" "deploy/x86"
#x64
deploy "msvc10/x64" "include" "deploy/x64"
