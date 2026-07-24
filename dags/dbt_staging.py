import pendulum
from datetime import timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

local_timezone = pendulum.timezone("Asia/Jakarta")

default_args = {
    "owner": "neinAlkem",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="dbt_staging",
    default_args=default_args,
    description="Build staging models",
    start_date=pendulum.datetime(2026, 1, 1, tz=local_timezone),
    schedule=None,
    catchup=False,
    tags=["dbt", "staging"],
) as dag:

    dbt_staging = BashOperator(
        task_id="dbt_build_staging",
        cwd="/opt/airflow/include/dbt/olist_analytics",
        bash_command="dbt build --select staging",
    )

    trigger_warehouse = TriggerDagRunOperator(
        task_id="trigger_warehouse",
        trigger_dag_id="dbt_warehouse",
        wait_for_completion=True,
        allowed_states=["success"],
        failed_states=["failed"],
        reset_dag_run=True,
    )

    dbt_staging >> trigger_warehouse