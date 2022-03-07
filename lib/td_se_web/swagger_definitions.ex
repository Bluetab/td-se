defmodule TdSeWeb.SwaggerDefinitions do
  @moduledoc false
  import PhoenixSwagger

  def global_search_definitions do
    %{
      IndexList:
        swagger_schema do
          title("Index List")
          description("A collection of indices with results")
          type(:array)
          items(Schema.ref(:Index))
        end,
      Index:
        swagger_schema do
          title("An index")
          description("An index with all the search items")
          type(:object)

          properties do
            index(:string)
            results(Schema.ref(:Results))
          end
        end,
      Results:
        swagger_schema do
          title("Search Results")
          description("Results retrieved for a given index")
          type(:array)
          items(Schema.ref(:Result))
        end,
      Result:
        swagger_schema do
          title("Result")
          description("An entry representig a result of the performed search")
          type(:object)

          properties do
            id(:integer)
            index(:string)
            name(:string)
            description(:string)
          end
        end,
      GlobalSearchResponse:
        swagger_schema do
          properties do
            data(Schema.ref(:IndexList))
          end
        end,
      GlobalSearchRequest:
        swagger_schema do
          properties do
            query(:string, "Query string", required: false)
            indexes(:array, "Indexes", required: false)
          end

          example(%{
            query: "searchterm",
            indexes: ["concepts", "structures", "ingests"]
          })
        end
    }
  end
end
