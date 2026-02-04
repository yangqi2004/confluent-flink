CREATE MODEL sagemaker_claim_model3
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
  'sagemaker.connection' = 'qyang-sagemaker-connection3',

  -- IO format (SageMaker defaults to CSV, but many models diverge)
  'sagemaker.input_format'  = 'JSON',
  'sagemaker.output_format' = 'JSON:Output',

  -- HTTP headers (often needed for SageMaker)
  'sagemaker.input_content_type'  = 'application/json',
  'sagemaker.output_content_type' = 'application/json'

  -- Optional, model‑specific knobs (only if your endpoint expects them):
  -- 'sagemaker.inference_component_name' = 'my-inference-component',
  -- 'sagemaker.target_model'            = 'my-model.tar.gz',
  -- 'sagemaker.target_variant'          = 'prod-variant'
);
SELECT * FROM `helathcare-topic`, 
  LATERAL TABLE(ML_PREDICT('sagemaker_claim_model3', `Admission Type`, `Age`, 
  `Billing Amount`, `Blood Type`, `Date of Admission`, `Discharge Date`, `Doctor`, `Gender`, 
  `Hospital`, `Insurance Provider`, `Medical Condition`, `Medication`, `Name`, `Room Number`, `Test Results`,map['debug', 'true'] ));
