from databricks.connect import DatabricksSession
import os
from dotenv import load_dotenv
from minio import Minio
import logging
import pandas as pd
import io

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

load_dotenv()

HOST = os.getenv('DATABRICKS_HOST')
TOKEN = os.getenv('DATABRICKS_TOKEN')
CATALOG = os.getenv('DATABRICKS_CATALOG')
MINIO_HOST = os.getenv('MINIO_HOST')
ACCESS_KEY = os.getenv('MINIO_ROOT_USER')
SECRET_KEY = os.getenv('MINIO_ROOT_PASSWORD')
BUCKET_NAME = os.getenv('BUCKET_NAME')

def load_source_to_bronze() -> None :
    """
    Function to send latest update files from MinIO bucket to Bronze/landing layer in Databricks
    """
    
    spark = (
        DatabricksSession.builder 
            .host(HOST) 
            .token(TOKEN)
            .serverless(True)
            .getOrCreate()
    )

    client = Minio(
        MINIO_HOST, 
        ACCESS_KEY, 
        SECRET_KEY, 
        secure=False
    )
    
    try:
         
        if 'bronze' not in [row for row in spark.sql('SHOW SCHEMAS IN {}'.format(CATALOG)).collect()] :
            spark.sql('CREATE SCHEMA IF NOT EXISTS {}.bronze'.format(CATALOG))
        
        for obj in client.list_objects(BUCKET_NAME, recursive=True):
            filename = obj.object_name
            table_name = filename[:-4]
            logger.info('Processing file: {}...'.format(filename))
            
            res = client.get_object(BUCKET_NAME, filename)
            data = io.BytesIO(res.read())
            
            spark_df = spark.createDataFrame
            (
                pd.read_csv(data)
                )
            
            logger.info('Writing file as table in Databricks: bronze.{}'.format(table_name))
            spark_df.write \
                .format('delta') \
                .mode('overwrite') \
                .saveAsTable('{}.bronze.{}'.format(CATALOG, table_name))
            logger.info('Success.')
            
    except Exception as e:
        logger.error('Error while writing into Bronze Table : {}'.format(e))
       
        
if __name__ == '__main__':
    create_bronze_layer()