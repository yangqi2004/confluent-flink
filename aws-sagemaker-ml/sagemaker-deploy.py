import boto3
import json
import os
import sagemaker
from sagemaker.estimator import Estimator
import time
from time import gmtime, strftime
import subprocess


#Setup
client = boto3.client(service_name="sagemaker")
runtime = boto3.client(service_name="sagemaker-runtime")
boto_session = boto3.session.Session()
s3 = boto_session.resource('s3')
region = 'us-east-1'

print(region)
sagemaker_session = sagemaker.Session()
role = "get the execution role"


# retrieve sklearn image
image_uri = sagemaker.image_uris.retrieve(
    framework="sklearn",
    region=region,
    version="1.4-2",
    py_version="py3",
    instance_type="ml.m5.large"
)

#Bucket for model artifacts
#Upload tar.gz to bucket
default_bucket = sagemaker_session.default_bucket()



model_path=default_bucket + "/shared/model.tar.gz"

print(model_path)

#Step 1: Model Creation
model_name = "qyang-healthcare-" + strftime("%H-%M-%S", gmtime())
print("Model name: " + model_name)
create_model_response = client.create_model(
    ModelName=model_name,
    Containers=[
        {
            "Image": image_uri,
            "Mode": "SingleModel",
            "ModelDataUrl": model_path,
            "Environment": {'SAGEMAKER_SUBMIT_DIRECTORY': model_path,
                           'SAGEMAKER_PROGRAM': 'inference.py'} 
        }
    ],
    ExecutionRoleArn=role,
)
print("Model Arn: " + create_model_response["ModelArn"])


#Step 2: EPC Creation
sklearn_epc_name = "qyang-healthcare-" + strftime("%H-%M-%S", gmtime())
endpoint_config_response = client.create_endpoint_config(
    EndpointConfigName=sklearn_epc_name,
    ProductionVariants=[
        {
            "VariantName": "sklearnvariant",
            "ModelName": model_name,
            "InstanceType": "ml.m5.large",
            "InitialInstanceCount": 1
        },
    ],
)
print("Endpoint Configuration Arn: " + endpoint_config_response["EndpointConfigArn"])


#Step 3: EP Creation
endpoint_name = "qyang-healthcare-ep" + strftime("%H-%M-%S", gmtime())
create_endpoint_response = client.create_endpoint(
    EndpointName=endpoint_name,
    EndpointConfigName=sklearn_epc_name,
)
print("Endpoint Arn: " + create_endpoint_response["EndpointArn"])


#Monitor creation
describe_endpoint_response = client.describe_endpoint(EndpointName=endpoint_name)
while describe_endpoint_response["EndpointStatus"] == "Creating":
    describe_endpoint_response = client.describe_endpoint(EndpointName=endpoint_name)
    print(describe_endpoint_response["EndpointStatus"])
    time.sleep(15)
print(describe_endpoint_response)
