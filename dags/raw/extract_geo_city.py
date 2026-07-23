import pandas as pd
import aiohttp
import asyncio
import logging
from dotenv import load_dotenv
import os
import json
from airflow.models import Variable

load_dotenv()

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

url = Variable.get('CITY_URL')
headers = {
    'X-Parse-Application-Id': str(Variable.get('CITY_HEADERS_APPLICATION')),
    'X-Parse-Master-Key': str(Variable.get('CITY_HEADERS_MASTER'))
} 
batch_limit = 1000

async def extract_cities():
    """
    Extracts cities and their geographic coordinates using Cursor Pagination.
    This bypasses the 10,000 skip limit by using the 'objectId' of the last 
    record to fetch the next batch.
    """
    
    async with aiohttp.ClientSession() as session:
        all_items = []
        has_more = True
        last_object_id = None
        batch_count = 1

        logger.info("Starting pagination fetching...")

        while has_more:
            params = {
                'limit': batch_limit,
                'order': 'objectId' 
            }
            
            if last_object_id:
                params['where'] = json.dumps({"objectId": {"$gt": last_object_id}})

            try:
                async with session.get(url, headers=headers, params=params) as response:
                    if response.status != 200:
                        logger.error(f'Error: {response.status}, response status: {response.reason}')
                        break
                    
                    data = await response.json()
                    results = data.get('results', [])
                    
                    if not results:
                        break
                    
                    all_items.extend(results)
                    
                    last_object_id = results[-1].get('objectId')
                    
                    logger.info(f"Batch {batch_count} complete. Total fetched: {len(all_items)}")
                    batch_count += 1
                    
                    if len(results) < batch_limit:
                        has_more = False
                        
            except Exception as e:
                logger.error(f'Error: {e}')
                break
                
        logger.info(f"Extraction complete! Processing {len(all_items)} records...")
        row_list = []
        for item in all_items:
            row_list.append({
                'city_name': item.get('name'),
                'latitude': item.get('location', []).get('latitude'),
                'longitude': item.get('location', []).get('longitude')
             })
            
        df = pd.DataFrame(row_list)
        
        df = df.drop_duplicates(subset=['city_name']) 
        
        df.to_csv('/opt/airflow/data/cities_geo.csv', index=False)
        logger.info(f"Data successfully saved! Total unique records: {len(df)}")

if __name__ == "__main__":
    asyncio.run(extract_cities())
            
                    
            
    
