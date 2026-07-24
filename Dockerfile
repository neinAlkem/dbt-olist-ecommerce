FROM apache/airflow:latest-python3.14

ENV UV_HTTP_TIMEOUT=300
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

USER root
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow
RUN uv pip install --no-cache-dir dbt-core dbt-databricks boto3 kagglehub minio databricks-connect
