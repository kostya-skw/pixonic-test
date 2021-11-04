#!/usr/bin/env python3

import socket
import os

#from subprocess import check_output
#def get_pid(name):
#    try:
#        return int(check_output(["pidof","-s",name]))
#    except:
#        return 0
def get_pid(_name,_ppid):
    for pid in os.listdir("/proc"):
        if pid.isdigit():
            try:
                with open("/proc/{}/stat".format(pid), encoding = 'utf-8') as f:
                    line = f.readline()
                    if _name in line:
                        ppid = int(line.split()[3])
                        if ppid == _ppid:
                            return pid
            except:
                pass
    return 0


def get_sockets(_pid):
    sockets = []
    try:
        for fdid in os.listdir("/proc/{}/fd".format(_pid)):
            fd = os.readlink("/proc/{}/fd/{}".format(_pid, fdid))
            if fd.split(":")[0] == "socket":
                data = fd.split(":")[1]
                sockets.append(int(data[1:-1]))
    except PermissionError:
        exit("Only root")
    return sockets


def find_port_in_sockets(_port, _sockets):
    with open("/proc/net/tcp", encoding = 'utf-8') as f:
        f.readline()
        for line in f:
            data = line.split()
            local_address = data[1]
            port = int(local_address.split(':')[1], 16)
            socket = int(data[9])
            if port==_port and socket in _sockets:
                return True
    return False

def check_socket(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex(('127.0.0.1', port))
    sock.close()
    return result


def main(name = 'nginx', ppid = 1, port = 80):
    pid = get_pid(name,ppid)
    if pid==0:
        exit("Error")

    sockets = get_sockets(pid)
    if len(sockets)==0:
        exit("Error")

    if not find_port_in_sockets(port, sockets):
        exit("Error")

    if check_socket(port) == 0:
        exit("OK")
    else:
        exit("WARN")

if __name__ == "__main__":
    main()
