import os

nginx_pid_file = '/run/nginx/nginx.pid' 

try:
    with open(nginx_pid_file) as file:
        nginx_pid = int(file.read())
        print(nginx_pid)
        os.kill(nginx_pid, 0)
except FileNotFoundError:
    print('Nginx pid file is not found at', nginx_pid_file)
except ProcessLookupError:
    print('Nginx process is not running')
except Exception as ex:
    print('Unable to detemine nginx process state')
