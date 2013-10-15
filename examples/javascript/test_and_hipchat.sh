#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

npm test
exit_status=$?

project_name="myproject"
hipchat_auth="mytoken"
hipchat_url="https://api.hipchat.com/v1/rooms/message?auth_token=$hipchat_auth&format=json"
hipchat_room="roomname"

function hipchat() {
  curl -d "room_id=$hipchat_room&from=Bait&message=$1&color=$2&notify=$3" $hipchat_url > /dev/null 2>&1
}

if [[ $exit_status -ne 0 ]]; then
  hipchat "Build+Status:+[$project_name]:+Failed" "red" "1"
else
  hipchat "Build+Status:+[$project_name]:+Passed" "green" "0"
fi

# istanbul text coverage output
cov_pct=$(tail -n2 coverage/*/coverage.txt | head -n1 | awk {'print $10'})
hipchat "Code+Coverage+[$project_name]:+$cov_pct%" "yellow" "0"

exit $exit_status

