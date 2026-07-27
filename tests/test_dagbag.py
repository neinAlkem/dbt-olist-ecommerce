def test_dags_integration(dagbag):
    assert dagbag.import_errors == {}, f'DAG import errors: {dagbag.import_errors}'
    print('============')
    print(dagbag.import_errors)
    
    expected_dags_id = ['extract_load_to_raw', 'dbt_staging', 'dbt_staging']
    loaded_dags_id = list(dagbag.dags.keys())
    print('=============')
    print(dagbag.dags.keys())
    
    for dag_id in expected_dags_id:
        assert dag_id in loaded_dags_id, f'DAG {dag_id} not found in DagBag'
    
    assert len(dagbag.dags) == 3
    print('=============')
    print(len(dagbag.dags))
    
    expected_taks_count = {
        'extract_load_to_raw': 7,
        'dbt_staging': 2,
        'data_warehouse': 1
    }
    print('=============')
    for dag_id, expected_count in expected_taks_count.items():
        dag = dagbag.get_dag(dag_id)
        actual_count = len(dag.tasks)
        print(f'{dag_id}: expected {expected_count}, actual {actual_count}')
        assert actual_count == expected_count, f'DAG {dag_id} has {actual_count} tasks, expected {expected_count}'