import os
import sys
import unittest
from unittest.mock import patch, MagicMock
import dotenv

dotenv.load_dotenv()
BUCKET_NAME = os.getenv('BUCKET_NAME')

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from pipelines.include.src.load_to_minio import get_files_path, upload_local_file, main

class TestGetFilesPath(unittest.TestCase):

    @patch('os.listdir')
    @patch('pipelines.include.src.load_to_minio.BASE_DIR', new_callable=MagicMock)
    def test_get_files_path_returns_csv_files(self, mock_base_dir, mock_listdir):
        
        mock_base_dir.__truediv__.return_value = '/fake/path/to/data'
        mock_listdir.return_value = ['file1.csv', 'file2.txt', 'file3.csv']

        result = get_files_path()

        self.assertEqual(result, ['file1.csv', 'file3.csv'])

    @patch('os.listdir')
    def test_get_files_path_raises_file_not_found_error_when_no_files(self, mock_listdir):
       
        mock_listdir.side_effect = FileNotFoundError()

        with self.assertRaises(FileNotFoundError):
            get_files_path()


class TestUploadLocalFile(unittest.TestCase):

    @patch('pipelines.include.src.load_to_minio.Minio')
    @patch('pipelines.include.src.load_to_minio.logger')
    def test_upload_local_file_creates_bucket_and_uploads_files(self, mock_logger, mock_minio):

        mock_client = MagicMock()
        mock_minio.return_value = mock_client
        mock_client.bucket_exists.return_value = False

        filelist = ['test1.csv', 'test2.csv']

        upload_local_file(filelist)
        
        mock_minio.assert_called_once()
        mock_client.bucket_exists.assert_called_once_with(BUCKET_NAME)  
        mock_client.make_bucket.assert_called_once_with(BUCKET_NAME)
        self.assertEqual(mock_client.fput_object.call_count, 2)
        mock_logger.info.assert_any_call('Uploading test1.csv...')
        mock_logger.info.assert_any_call('Successfuly loading test1.csv to bucket.')
        mock_logger.info.assert_any_call('Uploading test2.csv...')
        mock_logger.info.assert_any_call('Successfuly loading test2.csv to bucket.')


    @patch('pipelines.include.src.load_to_minio.Minio')
    @patch('pipelines.include.src.load_to_minio.logger')
    def test_upload_local_file_does_not_create_bucket_if_exists(self, mock_logger, mock_minio):

        mock_client = MagicMock()
        mock_minio.return_value = mock_client
        mock_client.bucket_exists.return_value = True

        filelist = ['test1.csv']

        upload_local_file(filelist)

        mock_client.bucket_exists.assert_called_once_with(BUCKET_NAME)
        mock_client.make_bucket.assert_not_called()
        mock_client.fput_object.assert_called_once()


class TestMain(unittest.TestCase):

    @patch('pipelines.include.src.load_to_minio.get_files_path')
    @patch('pipelines.include.src.load_to_minio.upload_local_file')
    def test_main_calls_get_files_path_and_upload_local_file(self, mock_upload, mock_get_files):
       
        mock_get_files.return_value = ['file1.csv', 'file2.csv']

        main()

        mock_get_files.assert_called_once()
        mock_upload.assert_called_once_with(['file1.csv', 'file2.csv'])


if __name__ == '__main__':
    unittest.main()