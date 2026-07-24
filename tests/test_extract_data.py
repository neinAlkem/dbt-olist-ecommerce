import os
import pytest
from unittest import mock
from dags.raw.extract_data import download_kaggle_dataset

def test_download_kaggle_dataset_missing_token():
    """
    Test that ValueError is raised when KAGGLE_API_TOKEN is not set.
    """
    
    with mock.patch.dict(os.environ, {}, clear=True):
        with mock.patch('dags.raw.extract_data.KAGGLE_API_TOKEN', None):
            with pytest.raises(ValueError, match="KAGGLE_API_TOKEN is not set"):
                download_kaggle_dataset("dummy/dataset", "/tmp/output")


def test_download_kaggle_dataset_creates_directory():
    """
    Test that output directory is created if it does not exist.
    """
    
    with mock.patch('dags.raw.extract_data.KAGGLE_API_TOKEN', 'fake-token'), \
         mock.patch('os.path.exists', return_value=False), \
         mock.patch('os.makedirs') as mock_makedirs, \
         mock.patch('kagglehub.dataset_download') as mock_download, \
         mock.patch('dags.raw.extract_data.logger') as mock_logger:

        download_kaggle_dataset("dummy/dataset", "/tmp/output")

        # Check that makedirs was called with the output_dir
        mock_makedirs.assert_called_once_with("/tmp/output")
        # Check that dataset_download was called with correct args
        mock_download.assert_called_once_with("dummy/dataset", force_download=True, output_dir="/tmp/output")
        # Check logging calls (optional)
        mock_logger.info.assert_any_call('Check for output directory avaibility')
        mock_logger.info.assert_any_call('Directory available!')
        mock_logger.info.assert_any_call('Downloading dataset...')
        mock_logger.info.assert_any_call('Dataset downloaded successfully!')

def test_download_kaggle_dataset_directory_exists():
    """
    Test that if output directory exists, makedirs is not called.
    """
    
    with mock.patch('dags.raw.extract_data.KAGGLE_API_TOKEN', 'fake-token'), \
         mock.patch('os.path.exists', return_value=True), \
         mock.patch('os.makedirs') as mock_makedirs, \
         mock.patch('kagglehub.dataset_download') as mock_download:

        download_kaggle_dataset("dummy/dataset", "/tmp/output")

        # makedirs should not be called
        mock_makedirs.assert_not_called()
        mock_download.assert_called_once_with("dummy/dataset", force_download=True, output_dir="/tmp/output")

def test_download_kaggle_dataset_propagates_exception():
    """
    Test that any exception from kagglehub is propagated.
    """
    
    with mock.patch('dags.raw.extract_data.KAGGLE_API_TOKEN', 'fake-token'), \
         mock.patch('os.path.exists', return_value=True), \
         mock.patch('kagglehub.dataset_download', side_effect=Exception("Kaggle error")):

        with pytest.raises(Exception, match="Kaggle error"):
            download_kaggle_dataset("dummy/dataset", "/tmp/output")