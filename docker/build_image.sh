#!/bin/bash
docker build -t madagascar .
docker build -t madagascar-x11 -f dockerfile-x11 .