defmodule TdSeWeb.ElasticIndexController do
  use TdSeWeb, :controller

  alias TdSe.ElasticIndexes
  # alias TdSe.ElasticIndexes.ElasticIndex

  action_fallback TdSeWeb.FallbackController

  def index(conn, _params) do
    claims = conn.assigns[:current_resource]

    with :ok <- Bodyguard.permit(ElasticIndexes, :index, claims) do
      elastic_indexes = ElasticIndexes.list_elastic_indexes()
      render(conn, "index.json", elastic_indexes: elastic_indexes)
    end
  end

  def delete(conn, %{"index_name" => index_name}) do
    claims = conn.assigns[:current_resource]

    with :ok <- Bodyguard.permit(ElasticIndexes, :delete, claims),
         {:ok, _} <- ElasticIndexes.delete_elastic_index(index_name) do
      send_resp(conn, :no_content, "")
    end
  end
end
