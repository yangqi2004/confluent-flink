## Testing
```
docker compose exec -it jobmanager bash -c "./bin/sql-client.sh"
CREATE CATALOG my_glue_catalog WITH (
  'type' = 'iceberg',
  'warehouse' = 's3://qyang-us-east-1/', -- S3 path where your data is stored
  'catalog-impl' = 'org.apache.iceberg.aws.glue.GlueCatalog',
  'glue.skip-name-validation'='true',
  'io-impl' = 'org.apache.iceberg.aws.s3.S3FileIO'
);

use catalog my_glue_catalog;
use  my_glue_catalog.`lkc-prvpdy`;
select * from customer_orders limit 10;
```

