if [[ $(gh run list -w pipeline -L 1 -b main -q '.[0].status' --json status) == 'completed' ]]; then echo "Success"; fi;
