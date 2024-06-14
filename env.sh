#!/usr/bin/env bash

#Debug
[ "$DEBUG" != "" ] && set -x

#Funcion de USO
usage () {
	echo "Usage: ./$0"
  exit $2
}
export $(grep -v '^#' .env | xargs)
