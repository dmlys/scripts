function edit()
{
	for path in "$@"; do
		path=`cygpath -w "$path"`
		cygstart "C:\Program Files\Notepad++\notepad++.exe" "\"$path\""
	done
}

function launch-ssh-agent()
{
	# launch ssh-agent if needed
	local STORED_SSH_AGENT_PID=0
	local PGREP_SSH_AGENT_PIDS=0
	local SSH_INFO=~/.ssh-agent-info
	
	while read -r line; do
		if [[ $line =~ SSH_AGENT_PID=([0-9]+) ]]; then
			STORED_SSH_AGENT_PID=${BASH_REMATCH[1]}
		fi
	done < $SSH_INFO
	
	PGREP_SSH_AGENT_PIDS=$(pgrep -x ssh-agent -d ' ')

	if [[ $? -ne 0 || ! "$PGREP_SSH_AGENT_PIDS" =~ $STORED_SSH_AGENT_PID ]]; then
		echo "~/.bashrc: Starting SSH Agent!"
		ssh-agent > $SSH_INFO
		source $SSH_INFO
		echo "~/.bashrc: SSH Agent running (PID: $SSH_AGENT_PID)"
	else
		echo "~/.bashrc: SSH Agent already running (PID: $PGREP_SSH_AGENT_PIDS)"
		source $SSH_INFO
	fi
}
