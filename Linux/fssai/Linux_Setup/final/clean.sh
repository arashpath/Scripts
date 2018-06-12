#!/bin/bash
# -*- coding: utf-8 -*-

rm -rvf /opt/{apache,DevEnv,APPS} \
    /etc/systemd/system/{apache.service,tomcat*.service} \
    /etc/profile.d/devEnv.sh
