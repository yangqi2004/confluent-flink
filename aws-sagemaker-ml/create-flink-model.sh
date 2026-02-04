#!/bin/bash

. ~/aws.env
confluent flink connection create qyang-sagemaker-connection3 \
  --cloud aws \
  --region us-east-1 \
  --environment env-m8pnj2 \
  --type sagemaker \
  --endpoint https://runtime.sagemaker.us-east-1.amazonaws.com/endpoints/qyang-healthcare-ep01-50-03/invocations \
  --aws-access-key $AWS_ACCESS_KEY_ID \
  --aws-secret-key $AWS_SECRET_ACCESS_KEY \

exit

CREATE MODEL sagemaker_prolonged_stay
INPUT (
  `Admission Type` VARCHAR(2147483647),
  `Age` DOUBLE,
  `Billing Amount` DOUBLE,
  `Blood Type` VARCHAR(2147483647),
  `Date of Admission` VARCHAR(2147483647),
  `Discharge Date` VARCHAR(2147483647),
  `Doctor` VARCHAR(2147483647),
  `Gender` VARCHAR(2147483647),
  `Hospital` VARCHAR(2147483647),
  `Insurance Provider` VARCHAR(2147483647),
  `Medical Condition` VARCHAR(2147483647),
  `Medication` VARCHAR(2147483647),
  `Name` VARCHAR(2147483647),
  `Room Number` VARCHAR(2147483647),
  `Test Results` VARCHAR(2147483647)
)
OUTPUT (
  score DOUBLE
)
COMMENT 'Claim risk model on AWS SageMaker'
WITH (
  -- Provider & task
  'provider' = 'sagemaker',
  'task'     = 'classification',

  -- Use the connection created via CLI
  'sagemaker.connection' = 'qyang-sagemaker-healthcare-connection',

  -- IO format (SageMaker defaults to CSV, but many models diverge)
  'sagemaker.input_format'  = 'JSON',
  'sagemaker.output_format' = 'JSON',

  -- HTTP headers (often needed for SageMaker)
  'sagemaker.input_content_type'  = 'application/json',
  'sagemaker.output_content_type' = 'application/json'

  -- Optional, model‑specific knobs (only if your endpoint expects them):
  -- 'sagemaker.inference_component_name' = 'my-inference-component',
  -- 'sagemaker.target_model'            = 'my-model.tar.gz',
  -- 'sagemaker.target_variant'          = 'prod-variant'
);
