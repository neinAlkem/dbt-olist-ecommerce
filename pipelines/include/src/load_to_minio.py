from minio import Minio
from minio.error import S3Error
import dotenv
import os
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parents[3]

dotenv.load_dotenv()
MINIO_HOST = os.getenv('MINIO_HOST')
ACCESS_KEY = os.getenv('MINIO_ROOT_USER')
SECRET_KEY = os.getenv('MINIO_ROOT_PASSWORD')
BUCKET_NAME = os.getenv('BUCKET_NAME')

def get_files_path() -> list[str]:
    """
    Use to list all the files in the data directory

    Raises:
        FileNotFoundError: raise an error if no files were found withing the data directory

    Returns:
        list[str]: list of all available data to be uploaded into miniIo
    """
    
    try:
        file_list = []
        for filename in os.listdir(os.path.join(BASE_DIR, 'data')):
            if filename.endswith('.csv'):
                file_list.append(filename)
                continue
            else:
                continue
    except:
        raise FileNotFoundError()

    return file_list
        
        
def upload_local_file(filelist: list[str]) -> None:
    """
    Function to create local connection via docker and upload files to the minIO

    Args:
        filelist (list[str]): list of all available files from get_files_path() function
    """
    
    client = Minio(
        MINIO_HOST, 
        ACCESS_KEY, 
        SECRET_KEY, 
        secure=False
    )
    
    try:
        if not client.bucket_exists(BUCKET_NAME):
            logger.warn('Bucket {} not exists, creating...'.format(BUCKET_NAME))
            client.make_bucket(BUCKET_NAME)
            logger.info('Bucket {} created.'.format(BUCKET_NAME))
            
        for file in filelist:
            logger.info('Uploading {}...'.format(file))
            client.fput_object(
                BUCKET_NAME, 
                file,
                os.path.join(BASE_DIR, 'data', file),
                'text/csv'
            )
            logger.info('Successfuly loading {} to bucket.'.format(file))
            
    except S3Error as e:
        logger.error('Loading data error: {}'.format(e))
        

def main():
    filename = get_files_path()
    upload_local_file(filename)
    
    
if __name__ == '__main__' :
    main()
    