#! /bin/bash 

echo "Running a system check..."
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT > /data/azure_task_3_attach_data_disk/app/todolist/static/files/task3.log

pip install -r /data/azure_task_3_attach_data_disk/app/requirements.txt
python3 /data/azure_task_3_attach_data_disk/app/manage.py migrate
python3 /data/azure_task_3_attach_data_disk/app/manage.py runserver 0.0.0.0:8080
