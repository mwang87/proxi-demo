import os
import subprocess
import redis
from rq import Worker, Queue, Connection

listen = ['default']
redis_url = os.getenv('REDISTOGO_URL', 'redis://localhost:6379')
conn = redis.from_url(redis_url)

def test_run():
    print 'RUNNING JOB'
    return "MING"

def execute_task_populate(task_id):
    cmd = "ruby ../populate_db_task.rb " + task_id
    print cmd
    subprocess.call([cmd], shell=True)
    
if __name__ == '__main__':
    with Connection(conn):
        worker = Worker(list(map(Queue, listen)))
        worker.work()