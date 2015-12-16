wait_pid_and_run_command(){
    echo "killing pid $1"
    kill "$1"
    while kill -0 "$1" 2>/dev/null; do
    	sleep 0.5
    done
    echo "pid $1 is finished"
    echo "running command: $2"
    echo `eval $2`
}

pids=$(ps -Ao pid,command | grep witness_node | grep data_dir | sort -d -k 4,4 | awk '{print $1}')
pids=($pids)

echo "${#pids[@]} witness nodes are running"

if [[ ${#pids[@]} != 4 ]]; then
    echo "expected 4 witness nodes to be running"
    exit
fi

OIFS="$IFS"; IFS=$'\n'; wns=($(<$1)); IFS="$OIFS"
if [[ ${#wns[@]} != 4 ]]; then
    echo "got ${#wns[@]} witness node commands in wns file"
    echo "please provide correct wns file with 4 entries"
    exit
fi

for i in "${!pids[@]}"; do 
    wait_pid_and_run_command "${pids[$i]}" "${wns[$i]}";
    sleep 500
done
