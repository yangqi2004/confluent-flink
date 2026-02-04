#!/bin/bash

. ~/aws.env
. ./python-sagemaker/bin/activate
python sagemaker-deploy.py
