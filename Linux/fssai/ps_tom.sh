#!/bin/bash
#Prints running java Processes
ps -aef | grep [j]ava | awk '{print $2" "$15}'