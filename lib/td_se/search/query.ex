defmodule TdSe.Search.Query do
  @moduledoc """
  Functions to construct search queries
  """

  @structures Application.compile_env(:td_se, :index_aliases)[:structures]
  @concepts Application.compile_env(:td_se, :index_aliases)[:concepts]
  @ingests Application.compile_env(:td_se, :index_aliases)[:ingests]

  @permission_to_alias %{
    "manage_confidential_business_concepts" => @concepts,
    "manage_confidential_structures" => @structures,
    "view_data_structure" => @structures,
    "view_published_business_concepts" => @concepts,
    "view_published_ingests" => @ingests
  }

  @match_none %{match_none: %{}}

  def build_query(permissions, indices, nil = _query_string) do
    build_query(permissions, indices)
  end

  def build_query(permissions, indices, query_string) when is_binary(query_string) do
    query_string = String.trim(query_string)

    permissions
    |> build_query(indices)
    |> put_query_string(query_string)
  end

  def build_query(permissions, indices) do
    permissions
    |> Map.take(Map.keys(@permission_to_alias))
    |> put_defaults()
    |> Enum.group_by(&permission_to_alias(&1, indices))
    |> Enum.reject(fn {{_key, index}, _} -> is_nil(index) end)
    |> Enum.map(&map_group/1)
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

  defp put_query_string(@match_none, _), do: @match_none
  defp put_query_string(query, ""), do: query

  defp put_query_string(%{bool: bool} = query, query_string) when is_binary(query_string) do
    must =
      query_string
      |> words()
      |> Enum.map(&maybe_add_wildcard/1)
      |> Enum.join(" ")
      |> simple_query_string()

    bool = put(bool, :must, must)

    %{query | bool: bool}
  end

  defp permission_to_alias({permission, _}, aliases) do
    case Map.get(@permission_to_alias, permission) do
      nil -> {nil, nil}
      key -> {key, Map.get(aliases, key)}
    end
  end

  defp map_group({group, permissions}) do
    acc = acc(group)

    permissions
    |> Enum.reduce_while(acc, &reduce_permission/2)
    |> bool()
  end

  defp acc({@structures, index}) do
    %{
      filter: term("_index", index),
      must_not: exists("deleted_at")
    }
  end

  defp acc({_, index}) do
    %{
      filter: [
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
    {:cont, put(acc, :filter, bool)}
  end

  defp reduce_permission({"manage_confidential_structures", :all}, acc), do: {:cont, acc}

  defp reduce_permission({"manage_confidential_structures", :none}, acc),
    do: {:cont, put(acc, :must_not, term("confidential", true))}

  defp reduce_permission({"manage_confidential_structures", domain_ids}, acc) do
    bool = either(%{"confidential" => false, "domain_ids" => domain_ids})
    {:cont, put(acc, :filter, bool)}
  end

  defp reduce_permission({"view_data_structure", :all}, acc), do: {:cont, acc}
  defp reduce_permission({"view_data_structure", :none}, _acc), do: {:halt, @match_none}

  defp reduce_permission({"view_data_structure", domain_ids}, acc) do
    {:cont, put(acc, :filter, term("domain_ids", domain_ids))}
  end

  defp reduce_permission({"view_published_business_concepts", :all}, acc), do: {:cont, acc}

  defp reduce_permission({"view_published_business_concepts", :none}, _acc),
    do: {:halt, @match_none}

  defp reduce_permission({"view_published_business_concepts", domain_ids}, acc) do
    {:cont, put(acc, :filter, term("domain_ids", domain_ids))}
  end

  defp reduce_permission({"view_published_ingests", :all}, acc), do: {:cont, acc}
  defp reduce_permission({"view_published_ingests", :none}, _acc), do: {:halt, @match_none}

  defp reduce_permission({"view_published_ingests", domain_ids}, acc) do
    {:cont, put(acc, :filter, term("domain_ids", domain_ids))}
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

  defp words(query_string) do
    Regex.split(~r/\s/, query_string, trim: true)
  end

  defp simple_query_string(query) do
    %{simple_query_string: %{query: query}}
  end

  def maybe_add_wildcard(query) do
    case String.last(query) do
      nil -> query
      "\"" -> query
      ")" -> query
      " " -> query
      _ -> query <> "*"
    end
  end

  def permissions_to_aliases, do: @permission_to_alias
end
