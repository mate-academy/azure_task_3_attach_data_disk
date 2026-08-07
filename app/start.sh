#! /bin/bash

set -e

echo "Running a system check..."
if ! mountpoint -q /data; then
    echo "/data is not mounted; refusing to start todoapp" >&2
    exit 1
fi

mkdir -p /data/app/todolist/static/files
if [ ! -w /data/app/todolist/static/files ]; then
    echo "/data/app/todolist/static/files is not writable" >&2
    exit 1
fi

if [ ! -f /data/app/manage.py ] || [ ! -f /data/app/requirements.txt ]; then
    echo "/data/app is missing manage.py or requirements.txt; deploy the app before starting todoapp" >&2
    exit 1
fi

lsblk -o NAME,HCTL,SIZE,MOUNTPOINT > /data/app/todolist/static/files/task3.log

VENV_PATH=/data/app/venv

if [ ! -x "$VENV_PATH/bin/python" ]; then
    if ! python3 -m venv --help >/dev/null 2>&1; then
        echo "python3-venv is required; install it with: sudo apt install python3-venv" >&2
        exit 1
    fi
    python3 -m venv "$VENV_PATH"
fi

"$VENV_PATH/bin/python" -m pip install -r /data/app/requirements.txt
"$VENV_PATH/bin/python" /data/app/manage.py migrate
exec "$VENV_PATH/bin/python" /data/app/manage.py runserver 0.0.0.0:8080 --noreload
