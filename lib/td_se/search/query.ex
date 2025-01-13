defmodule TdSe.Search.Query do
  @moduledoc """
  Functions to construct search queries
  """

  @structures Application.compile_env(:td_se, :index_aliases)[:structures]
  @concepts Application.compile_env(:td_se, :index_aliases)[:concepts]
  @ingests Application.compile_env(:td_se, :index_aliases)[:ingests]

  @structure_fields ~w(ngram_name*^3 ngram_original_name*^1.5 ngram_path* system.name)
  @concept_fields ~w(ngram_name*^3)
  @ingest_fields ~w(ngram_name*^3)

  @permission_to_alias %{
    "manage_confidential_business_concepts" => @concepts,
    "manage_confidential_structures" => @structures,
    "view_data_structure" => @structures,
    "view_published_business_concepts" => @concepts,
    "view_published_ingests" => @ingests
  }

  @match_none %{match_none: %{}}

  def build_query(permissions, indices) do
    build_group_query(permissions, indices, nil)
  end

  def build_query(permissions, indices, nil = query_string) do
    build_group_query(permissions, indices, query_string)
  end

  def build_query(permissions, indices, query_string) when is_binary(query_string) do
    query_string = String.trim(query_string)
    build_group_query(permissions, indices, query_string)
  end

  def build_group_query(permissions, indices, query) do
    permissions
    |> Map.take(Map.keys(@permission_to_alias))
    |> put_defaults()
    |> Enum.group_by(&permission_to_alias(&1, indices))
    |> Enum.reject(fn {{_key, index}, _} -> is_nil(index) end)
    |> Enum.map(&map_group(&1, query))
    |> Enum.reject(&(&1 == @match_none))
    |> some()
  end

  defp put_defaults(%{} = permissions) do
    %{
      "view_published_business_concepts" => "manage_confidential_business_concepts",
      "view_data_structure" => "manage_confidential_structures"
    }
    |> Enum.reduce(permissions, fn
      {k, v}, acc when is_map_key(acc, k) -> Map.put_new(acc, v, :none)
      {_, v}, acc when is_map_key(acc, v) -> Map.delete(acc, v)
      _, acc -> acc
    end)
  end

  defp permission_to_alias({permission, _}, aliases) do
    case Map.get(@permission_to_alias, permission) do
      nil -> {nil, nil}
      key -> {key, Map.get(aliases, key)}
    end
  end

  defp map_group({group, permissions}, query) do
    acc = acc(group)

    permissions
    |> Enum.reduce_while(acc, &reduce_permission/2)
    |> add_query_should(query, group)
    |> bool()
  end

  defp add_query_should(filters, nil, _), do: filters

  defp add_query_should(%{match_none: %{}} = filters, _, _), do: filters

  defp add_query_should(filters, query, {@structures, _}) do
    must = multi_match(query, @structure_fields)
    Map.update(filters, :must, must, &[must | &1])
  end

  defp add_query_should(filters, query, {@concepts, _}) do
    must = multi_match(query, @concept_fields)
    Map.update(filters, :must, must, &[must | &1])
  end

  defp add_query_should(filters, query, {@ingests, _}) do
    must = multi_match(query, @ingest_fields)
    Map.update(filters, :must, must, &[must | &1])
  end

  defp multi_match(query, fields) do
    %{
      multi_match: %{
        query: query,
        type: "bool_prefix",
        fields: fields,
        lenient: true,
        fuzziness: "AUTO"
      }
    }
  end

  defp acc({@structures, index}) do
    %{
      must: [term("_index", index)],
      must_not: exists("deleted_at")
    }
  end

  defp acc({_, index}) do
    %{
      must: [
        term("_index", index),
        term("status", "published")
      ]
    }
  end

  defp reduce_permission({"manage_confidential_business_concepts", :all}, acc), do: {:cont, acc}

  defp reduce_permission({"manage_confidential_business_concepts", :none}, acc),
    do: {:cont, put(acc, :must_not, term("confidential.raw", true))}

  defp reduce_permission({"manage_confidential_business_concepts", domain_ids}, acc) do
    bool = either(%{"confidential.raw" => false, "domain_ids" => domain_ids})
    {:cont, put(acc, :must, bool)}
  end

  defp reduce_permission({"manage_confidential_structures", :all}, acc), do: {:cont, acc}

  defp reduce_permission({"manage_confidential_structures", :none}, acc),
    do: {:cont, put(acc, :must_not, term("confidential", true))}

  defp reduce_permission({"manage_confidential_structures", domain_ids}, acc) do
    bool = either(%{"confidential" => false, "domain_ids" => domain_ids})
    {:cont, put(acc, :must, bool)}
  end

  defp reduce_permission({"view_data_structure", :all}, acc), do: {:cont, acc}
  defp reduce_permission({"view_data_structure", :none}, _acc), do: {:halt, @match_none}

  defp reduce_permission({"view_data_structure", domain_ids}, acc) do
    {:cont, put(acc, :must, term("domain_ids", domain_ids))}
  end

  defp reduce_permission({"view_published_business_concepts", :all}, acc), do: {:cont, acc}

  defp reduce_permission({"view_published_business_concepts", :none}, _acc),
    do: {:halt, @match_none}

  defp reduce_permission({"view_published_business_concepts", domain_ids}, acc) do
    {:cont, put(acc, :must, term("domain_ids", domain_ids))}
  end

  defp reduce_permission({"view_published_ingests", :all}, acc), do: {:cont, acc}
  defp reduce_permission({"view_published_ingests", :none}, _acc), do: {:halt, @match_none}

  defp reduce_permission({"view_published_ingests", domain_ids}, acc) do
    {:cont, put(acc, :must, term("domain_ids", domain_ids))}
  end

  defp put(query, key, clause) do
    Map.update(query, key, clause, fn acc -> [clause | List.wrap(acc)] end)
  end

  def term(field, [value]), do: %{term: %{field => value}}
  def term(field, values) when is_list(values), do: %{terms: %{field => values}}
  def term(field, value), do: %{term: %{field => value}}

  defp exists(field), do: %{exists: %{field: field}}

  defp either(%{} = entries) when map_size(entries) > 1 do
    entries
    |> Enum.reduce(%{}, fn {k, v}, acc -> put(acc, :should, term(k, v)) end)
    |> bool()
  end

  defp some([]), do: @match_none
  defp some([query]), do: query

  defp some(queries) when is_list(queries),
    do: %{bool: %{should: queries, minimum_should_match: 1}}

  defp bool(%{match_none: _} = clauses), do: clauses
  defp bool(%{} = clauses), do: %{bool: clauses}

  def permissions_to_aliases, do: @permission_to_alias
end
