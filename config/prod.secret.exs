use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :td_se, TdSeWeb.Endpoint,
  secret_key_base: "bbia29JeljAxzYeb8If4wXVoC+ETCjfNAwijzzC5ajuDF3ysPA/91ktNOGm0YyaA"

config :td_se, :elasticsearch,
  search_service: TdSe.Search,
  es_host: "${ES_HOST}",
  es_port: "${ES_PORT}",
  type_name: "doc"

