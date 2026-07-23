import pendulum
from datetime import timedelta

from airflow import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

from raw.extract_data import download_kaggle_dataset
from raw.extract_geo_city import extract_cities
from raw.extract_geo_zipcodes import extract_zipcodes
from raw.load_to_minio import main as load_to_minio

from warehouse.schema_init import init_warehouse_schema
from warehouse.load_to_raw import load_source_to_raw

local_timezone = pendulum.timezone("Asia/Jakarta")

default_args = {
    "owner": "neinAlkem",
    "depends_on_past": False,
    "email": ["kaptenbagaz@gmail.com"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="extract_load_to_raw",
    default_args=default_args,
    description="Extract source data and load into Databricks Raw",
    start_date=pendulum.datetime(2026, 1, 1, tz=local_timezone),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,
    dagrun_timeout=timedelta(hours=1),
    tags=["extract", "raw", "minio"],
) as dag:

    extract_dataset = download_kaggle_dataset()
    extract_city = extract_cities()
    extract_zipcodes = extract_zipcodes()
    upload_to_minio = load_to_minio()
    init_schema = init_warehouse_schema()
    load_raw = load_source_to_raw()
    
    trigger_staging = TriggerDagRunOperator(
        task_id="trigger_staging",
        trigger_dag_id="dbt_staging",
        wait_for_completion=True,
        allowed_states=["success"],
        failed_states=["failed"],
        reset_dag_run=True,
    )

    (
        [extract_dataset, extract_city, extract_zipcodes] >> upload_to_minio >> init_schema >> load_raw >> trigger_staging
    )