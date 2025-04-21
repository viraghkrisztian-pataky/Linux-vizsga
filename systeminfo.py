# -*- coding: utf-8 -*-
import commands
import psutil
import time
import re
import os


def get_start_time():
    '''
    获取启动时长
    :return: 成功：开机秒数
            失败：False
    '''
    errorcode, result = commands.getstatusoutput('cat /proc/uptime')
    if 0 == errorcode:
        start_time = result.split(' ')[0]
        return start_time
    else:
        return False


def get_now_time():
    '''
    获取当前时间
    :return: 当前时间
    '''
    return time.strftime("%Y/%m/%d  %H:%M:%S")  # 带日期的12小时格式


def get_cpu_used_percent():
    '''
    获取CPU占用率
    :return: CPU占用率
    '''
    cpu_used_percent = psutil.cpu_percent(interval=1)
    return cpu_used_percent


def get_cpu_free_percent():
    '''
    获取CPU剩余率
    :return: CPU剩余率
    '''
    cpu_free_percent = 100 - psutil.cpu_percent(interval=1)
    return cpu_free_percent


def get_cpu_free_percent_no_blocking():
    '''
    获取CPU剩余率
    :return: CPU剩余率
    '''
    cpu_free_percent = 100 - psutil.cpu_percent(interval=None)
    return cpu_free_percent


def get_mem_used_percent():
    '''
    获取内存占用率
    :return: 内存占用率
    '''
    mem = psutil.virtual_memory()
    return mem.percent


def get_mem_free_percent():
    '''
    获取内存剩余率
    :return: 内存剩余率
    '''
    mem = psutil.virtual_memory()
    return 100-mem.percent


def get_disk_free():
    '''
    获取磁盘剩余空间
    :return: 磁盘剩余空间（B）
    '''
    disk_free = psutil.disk_usage('/').free
    return disk_free


def get_disk_used():
    '''
    获取磁盘占用空间
    :return: 磁盘占用空间（B）
    '''
    disk_free = psutil.disk_usage('/').used
    return disk_free


def get_disk_free_percent():
    '''
    获取磁盘剩余空间百分比
    :return: 磁盘剩余空间百分比（float）
    '''
    disk_free_percent = 100.0 - psutil.disk_usage('/').percent
    return disk_free_percent


def get_disk_used_percent():
    '''
    获取磁盘占用空间百分比
    :return: 磁盘占用空间百分比（float）
    '''
    disk_used_percent = psutil.disk_usage('/').percent
    return disk_used_percent


def get_ip_info():
    '''
    获取IP信息
    :return: IP地址、子网掩码、网关组成的元组
    '''
    with open('/etc/network/interfaces', 'r') as f:
        data = f.read()
        ipaddr = re.search(r"address +([0-9.]{7,17})", data).group(1)
        netmask = re.search(r"netmask +([0-9.]{7,17})", data).group(1)
        gateway = re.search(r"gateway +([0-9.]{7,17})", data).group(1)
        return ipaddr, netmask, gateway


def set_now_time(year, month, day, hour, minute, second):
    '''
    设置系统时间
    :param year: 年
    :param month: 月
    :param day: 日
    :param hour: 时
    :param minute: 分
    :param second: 秒
    :return: 成功 ：0
             失败 ：-1 ： 执行命令失败
    '''
    setday = 'date -s ' + str(year) + '-' + str(month) + '-' + str(day)
    settime = 'date -s ' + str(hour) + ':' + str(minute) + ':' + str(second)
    errorcode, result = commands.getstatusoutput(setday)
    if errorcode != 0:
        return -1
    errorcode, result = commands.getstatusoutput(settime)
    if errorcode != 0:
        return -1
    return 0


def set_ip_info(ipaddr_new, netmask_new, gateway_new):
    '''
    设置IP
    :param ipaddr_new: 更改后的IP地址
    :param netmask_new: 更改后的子网掩码
    :param gateway_new: 更改后的网关
    :return:
    '''
    ipaddr_old, netmask_old, gateway_old = get_ip_info()
    data = ''
    with open('/etc/network/interfaces', 'r') as f:
        data = f.read()
        data = data.replace(ipaddr_old, ipaddr_new)
        data = data.replace(netmask_old, netmask_new)
        data = data.replace(gateway_old, gateway_new)
    with open('/etc/network/interfaces', 'w') as f:
        f.write(data)
    os.system('reboot')
