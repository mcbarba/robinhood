#!/usr/bin/env bash

#Debug
[ "$DEBUG" != "" ] && set -x

#Function usage
usage () {
	echo "Usage: $0 <TYPE>" 
  echo "folders -> folder_config"
  echo "host tag group -> host_tag_group"

  exit $2
}

TYPE=$1
[ "$TYPE" == "" ] && usage

USERNAME=$CMK_USER
PASSWORD=$CMK_PASS
SITE=$CMK_SITE
HOST=$CMK_HOST
PROTOCOL=$CMK_PROTOCOL
API_URL="$PROTOCOL://$HOST/$SITE/check_mk/api/1.0"

  curl -G -s -k\
    --request GET \
    --header "Authorization: Bearer $USERNAME $PASSWORD" \
    --header "Accept: application/json" \
    --data-urlencode 'parent=/' \
    --data-urlencode 'recursive=True' \
    --data-urlencode 'show_hosts=False' \
    "$API_URL/domain-types/$TYPE/collections/all"


