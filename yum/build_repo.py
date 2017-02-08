#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import os
import commands
from tools import *


def backuprepo():
    repo_path = '/etc/yum.repos.d/'
    backup_path = '/etc/yum.repos.d/backup/'
    if os.path.exists(backup_path) is not True:
        os.mkdir(backup_path)

    cmd = 'mv ' + repo_path + '*.repo ' + backup_path
    os.system(cmd)
    return

def reBackuprepo():
    repo_path = '/etc/yum.repos.d/'
    backup_path = '/etc/yum.repos.d/backup/'
    if os.path.exists(backup_path) is not True:
        os.mkdir(backup_path)

    cmd = 'mv ' + backup_path + '*.repo ' + repo_path
    os.system(cmd)
    return


def cleanrepo():
    if os.path.exists('/etc/yum.repos.d/backup2/') is not True:
        os.mkdir('/etc/yum.repos.d/backup2/')
    cmd = 'mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup2/'
    os.system(cmd)
    cmd = 'mv /etc/yum.repos.d/backup2/vdi_local.repo /etc/yum.repos.d/'
    os.system(cmd)
    return


def makerepo():
    repo_comment = '''
[vdi_local]
name=vdi_local
baseurl=file:///mnt/vdi_cdrom
enabled=1
gpgcheck=0
'''
    repo_path = '/etc/yum.repos.d/vdi_local.repo'

    repo_file = open(repo_path, 'w')
    repo_file.truncate(0)
    repo_file.write(repo_comment)
    repo_file.close()

    cmd = 'yum makecache'
    os.system(cmd)
    cleanrepo()
    cleanrepo()
    return


def mountCD():
    if os.path.exists('/dev/cdrom'):
        cd = '/dev/cdrom'
        cmd = 'mount ' + cd + ' /mnt/vdi_cdrom'
        os.system(cmd)
    line = commands.getoutput('ls /mnt/vdi_cdrom')
    if line != "":
        pass
    else:
        print
        colore_str("挂载CD失败，请手动挂载光盘或ISO到/mnt/vdi_cdrom后再执行安装......", Colore.red)
        exit(1)
    return


def makemount():
    if os.path.exists('/mnt/vdi_cdrom'):
        line = commands.getoutput('ls /mnt/vdi_cdrom')
        if line != "":
            pass
        else:
            mountCD()
    else:
        cmd = 'mkdir /mnt/vdi_cdrom'
        os.system(cmd)
        mountCD()
    if os.path.exists('/mnt/gluster-rpm'):
        pass
    else:
        if os.path.exists('../gluster-rpm'):
            cmd = '\cp -rf ../gluster-rpm /mnt/'
            os.system(cmd)
    line = commands.getoutput('ls /mnt/gluster-rpm/rpm')
    if line != "":
        pass
    else:
        print
        colore_str("拷贝gluster-rpm失败，请检查原因......", Colore.red)
        exit(1)
    return


if __name__ == '__main__':
    makemount()
    backuprepo()
    makerepo()






