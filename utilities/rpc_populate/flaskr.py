
import os
from flask import Flask, request, redirect, url_for, send_file, render_template

import random
import string
import json


import redis
from rq import Worker, Queue, Connection
from rq.job import Job

from worker import test_run
from worker import execute_task_populate
#Configuration


app = Flask(__name__, static_folder='./static', static_url_path='/results')
app.debug = True
app.config['UPLOAD_FOLDER'] = './uploads'
app.config['OUTPUT_FOLDER'] = './output'
app.config['SCRATCH_FOLDER'] = './scratch'

redis_url = os.getenv('REDISTOGO_URL', 'redis://localhost:6379')
conn = redis.from_url(redis_url)
q = Queue(connection=conn)

@app.route('/', methods=['GET'])
def renderhomepage():
    return render_template('homepage.html')

@app.route('/test_run_job', methods=['GET'])
def testrunjob():
    job = q.enqueue_call(
        func=test_run, args=(), result_ttl=86000
    )
    print(job.get_id())
    return job.get_id()


    
@app.route("/results/<job_key>", methods=['GET'])
def get_results(job_key):
    job = Job.fetch(job_key, connection=conn)

    if job.is_finished:
        return "DONE!", 200
    else:
        return "Running, Refresh!", 202
    
@app.route('/run_job', methods=['POST'])
def runjob():
    task_id = request.form["task_id"]
    job = q.enqueue_call(
        func=execute_task_populate, args=([task_id]), result_ttl=86000, timeout=3600
    )
    print(job.get_id())
    return render_template('submission.html', job_id = job.get_id())



    
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
