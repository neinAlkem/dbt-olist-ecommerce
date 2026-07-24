import pendulum
from datetime import timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

local_timezone = pendulum.timezone("Asia/Jakarta")

default_args = {
    "owner": "neinAlkem",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="dbt_warehouse",
    default_args=default_args,
    description="Build warehouse models",
    start_date=pendulum.datetime(2026, 1, 1, tz=local_timezone),
    schedule=None,
    catchup=False,
    tags=["dbt", "warehouse"],
) as dag:

    dbt_warehouse = BashOperator(
        task_id="dbt_build_warehouse",
        cwd="/opt/airflow/include/dbt/olist_analytics",
        bash_command="dbt build --select warehouse",
    )