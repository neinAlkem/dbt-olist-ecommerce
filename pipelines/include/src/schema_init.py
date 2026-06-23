from databricks.connect import DatabricksSession
import os
from dotenv import load_dotenv
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

load_dotenv()

HOST = os.getenv('DATABRICKS_HOST')
TOKEN = os.getenv('DATABRICKS_TOKEN')
CATALOG = os.getenv('DATABRICKS_CATALOG')


def init_warehouse_schema(schema_list: list[str]) -> None :
    """
    Function to check for catalog and schema avaibility in Databricks Delta Lake, auto create if not exists

    Args:
        schema_list (list[str]): List of warehouse schema / layers
    """
    
    spark = (
        DatabricksSession.builder 
            .host(HOST) 
            .token(TOKEN)
            .serverless(True)
            .getOrCreate()
    )
    
    try:
        
        logger.info('Checking for catalog avaibility...')
        catalogs = [row.catalog for row in spark.sql('SHOW CATALOGS').collect()]
        
        if CATALOG not in catalogs :
            logger.info('Catalog not exists, creating...')
            spark.sql('CREATE CATALOG IF NOT EXISTS {}'.format(CATALOG))
        logger.info('Catalog found.')
            
        logger.info('Checking for schema avaibility...')
        schemas = [row.databaseName for row in spark.sql('SHOW SCHEMAS IN {}'.format(CATALOG)).collect()]
        
        for schema in schema_list :
            if schema not in schemas :
                logger.info('Schema not exists, creating {}...'.format(schema))
                spark.sql('CREATE SCHEMA IF NOT EXISTS {}.{}'.format(CATALOG, schema))
                logger.info('Schema {}, created.'.format(schema))
            logger.info('Schema {} found.'.format(schema))
            
    except Exception as e:
        logger.error('Error while creating schema and catalog: {}'.format(e))
       
        
if __name__ == '__main__':
    schemas = ['staging' , 'warehouse', 'marts']
    init_warehouse_schema(schemas)