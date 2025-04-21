# -*- coding: utf-8 -*-
import subprocess
import psutil
import time
import re
import os

# Python 3 kompatibilis helyettesítője a commands.getstatusoutput-nak
def getstatusoutput(cmd):
    try:
        result = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, text=True)
        return 0, result.strip()
    except subprocess.CalledProcessError as e:
        return e.returncode, e.output.strip()

def get_start_time():
    errorcode, result = getstatusoutput('cat /proc/uptime')
    if errorcode == 0:
        start_time = result.split(' ')[0]
        return start_time
    else:
        return False

def get_now_time():
    return time.strftime("%Y/%m/%d  %H:%M:%S")

def get_cpu_used_percent():
    return psutil.cpu_percent(interval=1)

def get_cpu_free_percent():
    return 100 - psutil.cpu_percent(interval=1)

def get_cpu_free_percent_no_blocking():
    return 100 - psutil.cpu_percent(interval=None)

def get_mem_used_percent():
    return psutil.virtual_memory().percent

def get_mem_free_percent():
    return 100 - psutil.virtual_memory().percent

def get_disk_free():
    return psutil.disk_usage('/').free

def get_disk_used():
    return psutil.disk_usage('/').used

def get_disk_free_percent():
    return 100.0 - psutil.disk_usage('/').percent

def get_disk_used_percent():
    return psutil.disk_usage('/').percent

def get_ip_info():
    '''
    Csak akkor működik, ha /etc/network/interfaces valóban konfigurálva van!
    '''
    try:
        with open('/etc/network/interfaces', 'r') as f:
            data = f.read()
            ipaddr = re.search(r"address +([0-9.]{7,17})", data).group(1)
            netmask = re.search(r"netmask +([0-9.]{7,17})", data).group(1)
            gateway = re.search(r"gateway +([0-9.]{7,17})", data).group(1)
            return ipaddr, netmask, gateway
    except Exception as e:
        print("Hiba az IP-információ lekérdezésénél:", e)
        return None, None, None

def set_now_time(year, month, day, hour, minute, second):
    setday = f'date -s "{year}-{month}-{day}"'
    settime = f'date -s "{hour}:{minute}:{second}"'
    errorcode, result = getstatusoutput(setday)
    if errorcode != 0:
        return -1
    errorcode, result = getstatusoutput(settime)
    if errorcode != 0:
        return -1
    return 0

def set_ip_info(ipaddr_new, netmask_new, gateway_new):
    ipaddr_old, netmask_old, gateway_old = get_ip_info()
    if not ipaddr_old or not netmask_old or not gateway_old:
        return -1

    try:
        with open('/etc/network/interfaces', 'r') as f:
            data = f.read()
            data = data.replace(ipaddr_old, ipaddr_new)
            data = data.replace(netmask_old, netmask_new)
            data = data.replace(gateway_old, gateway_new)

        with open('/etc/network/interfaces', 'w') as f:
            f.write(data)

        subprocess.run(['reboot'])  # újraindítás
    except Exception as e:
        print("Hiba az IP beállításakor:", e)
        return -1

    return 0
