#! /bin/bash

set -e

echo "Running a system check..."
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT > /data/app/todolist/static/files/task3.log

VENV_PATH=/data/app/venv

if [ ! -x "$VENV_PATH/bin/python" ]; then
    python3 -m venv "$VENV_PATH"
fi

"$VENV_PATH/bin/pip" install -r /data/app/requirements.txt
"$VENV_PATH/bin/python" /data/app/manage.py migrate
exec "$VENV_PATH/bin/python" /data/app/manage.py runserver 0.0.0.0:8080
