import pytest
import logging
from unittest.mock import patch, MagicMock
from dags.warehouse.schema_init import init_warehouse_schema

@pytest.fixture
def mock_spark():
    """
    Fixture to mock the DatabricksSession builder chain and return the mock Spark session.
    """
    with patch('dags.warehouse.schema_init.DatabricksSession') as mock_session:
        # Mock the chained builder methods: .builder.host().token().serverless().getOrCreate()
        mock_builder = mock_session.builder
        mock_host = mock_builder.host.return_value
        mock_token = mock_host.token.return_value
        mock_serverless = mock_token.serverless.return_value
        mock_spark_instance = mock_serverless.getOrCreate.return_value
        
        yield mock_spark_instance

@patch('dags.warehouse.schema_init.CATALOG', 'test_catalog')
def test_init_creates_missing_catalog_and_schemas(mock_spark, caplog):
    """
    Test scenario: Neither the catalog nor the schemas exist.
    The function should trigger CREATE statements for all of them.
    """
    # 1. Setup Mock Returns for spark.sql(...).collect()
    def mock_sql_side_effect(query):
        mock_df = MagicMock()
        if 'SHOW CATALOGS' in query:
            # Return empty list, simulating catalog doesn't exist
            mock_df.collect.return_value = []
        elif 'SHOW SCHEMAS' in query:
            # Return empty list, simulating schemas don't exist
            mock_df.collect.return_value = []
        return mock_df
    
    mock_spark.sql.side_effect = mock_sql_side_effect

    # 2. Execute the function
    with caplog.at_level(logging.INFO):
        init_warehouse_schema(['staging', 'warehouse'])

    # 3. Assertions
    # Check that CREATE CATALOG was called
    mock_spark.sql.assert_any_call('CREATE CATALOG IF NOT EXISTS test_catalog')
    
    # Check that CREATE SCHEMA was called for both schemas
    mock_spark.sql.assert_any_call('CREATE SCHEMA IF NOT EXISTS test_catalog.staging')
    mock_spark.sql.assert_any_call('CREATE SCHEMA IF NOT EXISTS test_catalog.warehouse')
    
    # Check logs
    assert 'Catalog not exists, creating...' in caplog.text
    assert 'Schema not exists, creating staging...' in caplog.text

@patch('dags.warehouse.schema_init.CATALOG', 'test_catalog')
def test_init_skips_creation_if_already_exists(mock_spark, caplog):
    """
    Test scenario: The catalog and schemas already exist.
    The function should NOT trigger any CREATE statements.
    """
    # Mock row objects representing existing catalog and schemas
    mock_catalog_row = MagicMock()
    mock_catalog_row.catalog = 'test_catalog'
    
    mock_schema_row = MagicMock()
    mock_schema_row.databaseName = 'staging'

    def mock_sql_side_effect(query):
        mock_df = MagicMock()
        if 'SHOW CATALOGS' in query:
            mock_df.collect.return_value = [mock_catalog_row]
        elif 'SHOW SCHEMAS' in query:
            mock_df.collect.return_value = [mock_schema_row]
        return mock_df

    mock_spark.sql.side_effect = mock_sql_side_effect

    with caplog.at_level(logging.INFO):
        init_warehouse_schema(['staging'])

    # Assertions: Make sure CREATE was NEVER called
    for call in mock_spark.sql.call_args_list:
        args, _ = call
        assert 'CREATE' not in args[0]

    assert 'Catalog found.' in caplog.text
    assert 'Schema staging found.' in caplog.text

@patch('dags.warehouse.schema_init.CATALOG', 'test_catalog')
def test_init_handles_exceptions(mock_spark, caplog):
    """
    Test scenario: The Spark session throws an error during execution.
    The function should catch it and log an error.
    """
    # Force spark.sql to raise an exception
    mock_spark.sql.side_effect = Exception("Simulated Databricks Error")

    with caplog.at_level(logging.ERROR):
        init_warehouse_schema(['staging'])

    # Assert that the exception was caught and logged properly
    assert 'Error while creating schema and catalog: Simulated Databricks Error' in caplog.text


if __name__ == '__main__':
    pytest.main()