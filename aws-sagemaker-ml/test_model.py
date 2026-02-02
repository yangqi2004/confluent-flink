import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import boto3
import json
import pandas as pd
import os

for dirname, _, filenames in os.walk('~/data/'):
    for filename in filenames:
        print(os.path.join(dirname, filename))


X_test = pd.read_csv('./data/healthcare_dataset.csv')

runtime_client = boto3.client('sagemaker-runtime')
content_type = "application/json"

input_data = X_test.iloc[31:100].to_json()
request_body = {"Input": input_data}
data = json.loads(json.dumps(request_body))
payload = json.dumps(data)

# new_df = pd.DataFrame(json.loads(json.loads(payload)['Input']))
# print(X_test.iloc[1:3])
# print(new_df.shape)
# print(new_df)


endpoint_name = "qyang-healthcare-ep23-19-04"

response = runtime_client.invoke_endpoint(
    EndpointName=endpoint_name,
    ContentType=content_type,
    Body=payload)
result = json.loads(response['Body'].read().decode())['Output']
print(result)
