#!/bin/bash

. ~/aws.env
. ./python-sagemaker/bin/activate
python test_model.py
