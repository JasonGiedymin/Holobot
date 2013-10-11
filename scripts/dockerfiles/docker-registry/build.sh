#!/bin/bash
sudo docker build -t 10.10.10.12:5000/docker-registry .
sudo docker push 10.10.10.12:5000/docker-registry