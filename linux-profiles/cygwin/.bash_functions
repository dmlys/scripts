function edit()
{
	for path in "$@"; do
		path=`cygpath -w "$path"`
		cygstart "C:\Program Files (x86)\Notepad++\notepad++.exe" "\"$path\""
	done
}
