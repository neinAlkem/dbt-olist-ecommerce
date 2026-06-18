import kagglehub
import dotenv
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

dotenv.load_dotenv()
KAGGLE_API_TOKEN = os.getenv("KAGGLE_API_TOKEN")
DATASET_PATH = os.getenv("KAGGLE_DATASET_NAME")

def download_kaggle_dataset(dataset:str, output_dir:str):
    """
    Download a dataset from Kaggle using the Kaggle API.

    Args:
        dataset (str): The Kaggle dataset identifier in the format 'username/dataset-name'.
        output_dir (str): The local directory where the dataset will be downloaded.
    """
    
    if not KAGGLE_API_TOKEN:
        raise ValueError("KAGGLE_API_TOKEN is not set in the environment variables.")
    
    logger.info('Check for output directory avaibility')
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    logger.info('Directory available!')
    
    try:
        logger.info('Downloading dataset...')
        kagglehub.dataset_download(dataset, force_download=True, output_dir=output_dir)
        logger.info('Dataset downloaded successfully!')
    except Exception as e:
        logger.error('Error downloading dataset: {}'.format(e))
        raise

if __name__ == "__main__":
    download_kaggle_dataset(DATASET_PATH, output_dir="../../../data/")

