local mimir = import 'mimir/mimir.libsonnet';

mimir {
  _config+:: {
    namespace: 'default',
    external_url: 'http://test',

    storage_backend: 'gcs',
    blocks_storage_bucket_name: 'blocks-bucket',

    ruler_enabled: true,
    ruler_storage_bucket_name: 'rules-bucket',

    alertmanager_enabled: true,
    alertmanager_storage_bucket_name: 'alerts-bucket',
  },

  ingester_env_map+:: {
    GOGC: 'off',
    GOMEMLIMIT: '1Gi',
  },

  store_gateway_env_map+:: {
    GOGC: 'off',
    GOMEMLIMIT: '2Gi',
  },
}
