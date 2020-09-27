#!/usr/bin/bash
# TODO: write a comment, and how git cherry actually works and why it does what i need
current_branch=`git rev-parse --abbrev-ref HEAD`
#echo "current_branch = $current_branch"

git branch | grep -v \* | while read -r branch; do
	if [ $branch = master ]; then continue; fi
	#echo "brrach = $branch"
	extra=`git cherry $current_branch $branch | grep -v \-`

	# no extra commits
	if [ -z "$extra" ]; then echo $branch; fi
done
