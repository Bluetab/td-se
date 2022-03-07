{:ok, _} = Application.ensure_all_started(:ex_machina)
Mox.defmock(ElasticsearchMock, for: Elasticsearch.API)

ExUnit.start()
