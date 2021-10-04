: # https://stackoverflow.com/questions/17510688/single-script-to-run-in-both-windows-batch-and-linux-bash
: # interlacing cmd and bash scripts in one file
:<<"::CMDLITERAL"
@GOTO :CMDSCRIPT
::CMDLITERAL

set -e
input="$1"
result="$2"
bitrate="$3"


#fdir=$(dirname "$input")
#fname=$(basename "$input")
path="${input%/*}"
filename="${input##*/}"

extension="${filename##*.}"
filename="${filename%.*}"
tmpfname=/data-store/tmp/output.mkv

#echo "$path"
#echo "$filename"
#echo "$extension"

ffmpeg    -i "$input" -an -sn -dn        -c:v libx264 -crf 17 -preset slow -tune film -profile:v high -level 4.1 -b:v $bitrate -pass 1 -passlogfile /tmp/ffmpeg -f null /dev/null && \
ffmpeg -y -i "$input" -map 0 -codec copy -c:v libx264 -crf 17 -preset slow -tune film -profile:v high -level 4.1 -b:v $bitrate -pass 2 -passlogfile /tmp/ffmpeg "$tmpfname"
mkvmerge "$tmpfname" --output "$result"

exit $?

:CMDSCRIPT
rem @echo off
setlocal
set input=%1
set result=%2
set bitrate=%3

REM for %%I in (%input%) do (
REM set filename=%%~nI
REM set extension=%%~xI
REM )

REM echo "%filename%"
REM echo "%extension%"

REM ffmpeg    -i "%input%" -an -sn -dn        -c:v libx264 -crf 17 -preset slow -tune film -profile:v high -level 4.1 -b:v %bitrate% -pass 1 -passlogfile "%TMP%\ffmpeg" -f null NUL && \
REM ffmpeg -y -i "%input%" -map 0 -codec copy -c:v libx264 -crf 17 -preset slow -tune film -profile:v high -level 4.1 -b:v %bitrate% -pass 2 -passlogfile "%TMP%\ffmpeg" "%result%"
ffmpeg    -i %input% -an -sn -dn        -c:v libx264 -crf 17 -preset slow -tune film -profile:v high -level 4.1 -b:v %bitrate% -pass 1 -f null NUL && \
ffmpeg -y -i %input% -map 0 -codec copy -c:v libx264 -crf 17 -preset slow -tune film -profile:v high -level 4.1 -b:v %bitrate% -pass 2 %result%

endlocal