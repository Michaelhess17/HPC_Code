#!/bin/bash
find . -name "output*" -type f -mmin +"$1" -delete
find . -name "error*" -type f -mmin +"$1" -delete
