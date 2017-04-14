#!/bin/bash

. ./config.cfg

get_token(){
    token=`curl -s -X POST $BASE_URL/v1/login -d '{"userName":"'$USERNAME'", "password":"'$PASSWORD'"}' | awk -F \" '{print $6}'`
    echo "$token" > /tmp/sry_token
}

token=`cat /tmp/sry_token 2>/dev/null`
if [ -z "$token" ];then
    get_token
fi

curl -s -X GET -H 'Authorization: '$token'' $BASE_URL/v1/aboutme | grep '"code":[[:space:]]*1' &>/dev/null && get_token

echo -n "$token"

