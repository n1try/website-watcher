
#!/bin/bash

# ---------------------------------------------------
# A bash script to watch multiple URLs at once, based
# on a simple JSON config file.
# Can also be used in a CRON job.
#
# Prerequisites:
# --------------
# - jq must be installed
#   - Debian / Ubuntu: apt install jq
#   - Fedora / RHEL: dnf install jq
# - watcher.py must be executable
#   - chmod +x watcher.py
# - batch.sh must be executable
#   - chmod +x batch.sh
#
# Example Usage:
# --------------
# ./batch.sh example/many.json --adapter stdout
# ---------------------------------------------------

jobs=$(cat $1 | jq -c '.[]')
total=$(jq length $1)
cur=1

for job in $jobs; do
    url=$(echo $job | jq -r '.url')
    tolerance=$(echo $job | jq -r '.tolerance')
    xpath=$(echo $job | jq -r '.xpath')

    if [ "$url" == "null" ]; then
        echo "Error: URL parameter missing for job $cur of $total"
        exit 1
    fi

    if [ "$tolerance" == "null" ]; then
        echo "Error: Tolerance parameter missing for job $cur of $total"
        exit 1
    fi

    if [ "$xpath" == "null" ]; then
        echo "Error: XPATH missing for job $cur of $total (just set it to '/' to watch whole document)"
        exit 1
    fi

    echo "[$cur/$total] Watching $url."
    
    start=`date +%s.%N`
    ./watcher.py -u $url -t $tolerance -x $xpath ${@:2}
    end=`date +%s.%N`

    echo "[$cur/$total] Took $(echo $end-$start | bc) seconds."
    echo ""

    cur=$((cur+1))
done