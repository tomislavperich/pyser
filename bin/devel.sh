#!/bin/sh


export BIN_DIR=`dirname $0`
export PROJECT_ROOT=`readlink -f "${BIN_DIR}/.."`
export OFFLINE="${OFFLINE:=no}"


if [ -f /usr/local/bin/cbsd ]; then
  backend_hostname=$(sudo cbsd jexec user=devel jname=pyserback hostname)
  sudo cbsd jexec user=devel jname=pyserback env OFFLINE=${OFFLINE} FLASK_ENV=development /usr/src/bin/init.sh
  sudo tmux new-session -s "pyser" -d "cbsd jexec user=devel jname=pyserback env OFFLINE=${OFFLINE} /usr/src/bin/devel.sh"
  sudo tmux split-window -h -p 50 -t 0 "sudo cbsd jexec user=devel jname=pyserfront env OFFLINE=${OFFLINE} BACKEND_URL=\"http://${backend_hostname}:5000\" /usr/src/bin/devel.sh"
  sudo tmux a -t "pyser"
else
  backend_hostname='localhost:5000'
  "${PROJECT_ROOT}/bin/download_repos.sh"
  env OFFLINE=${OFFLINE} FLASK_ENV=development "${PROJECT_ROOT}/services/backend/bin/init.sh"
  tmux new-session -s "pyser" -d "env OFFLINE=${OFFLINE} ${PROJECT_ROOT}/services/backend/bin/devel.sh"
  tmux split-window -h -p 50 -t 0 "env OFFLINE=${OFFLINE} BACKEND_URL=\"http://${backend_hostname}:5000\" ${PROJECT_ROOT}/services/frontend/bin/devel.sh"
  tmux a -t "pyser"
fi
