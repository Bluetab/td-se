{:ok, _} = Application.ensure_all_started(:ex_machina)

TdCache.Redix.del!()
ExUnit.start()
