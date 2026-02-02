#!/bin/bash

. ~/aws.env
. ~/python-jupyter/bin/activate
python sagemaker-deploy.py
