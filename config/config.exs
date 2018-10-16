# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Hashing algorithm
config :td_se, hashing_module: Comeonin.Bcrypt

# Configures the endpoint
config :td_se, TdSeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kOMRdB8CGJ31Wmi0gNOHIGJlF/ITlZZ8Uy0N/IJDpc5TKUU9W1O8j/sCa5y9iMqw",
  render_errors: [view: TdSeWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: TdSe.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :td_se, TdSe.Auth.Guardian,
  allowed_algos: ["HS512"], # optional
  issuer: "tdauth",
  ttl: { 1, :hours },
  secret_key: "SuperSecretTruedat"

config :td_se, permission_resolver: TdPerms.Permissions

config :td_se, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [router: TdSeWeb.Router]
 }

 config :td_perms, permissions: [
   :is_admin,
   :create_acl_entry,
   :update_acl_entry,
   :delete_acl_entry,
   :create_domain,
   :update_domain,
   :delete_domain,
   :view_domain,
   :create_business_concept,
   :create_data_structure,
   :update_business_concept,
   :update_data_structure,
   :send_business_concept_for_approval,
   :delete_business_concept,
   :delete_data_structure,
   :publish_business_concept,
   :reject_business_concept,
   :deprecate_business_concept,
   :manage_business_concept_alias,
   :view_data_structure,
   :view_draft_business_concepts,
   :view_approval_pending_business_concepts,
   :view_published_business_concepts,
   :view_versioned_business_concepts,
   :view_rejected_business_concepts,
   :view_deprecated_business_concepts,
   :manage_business_concept_links,
   :manage_quality_rule,
   :manage_confidential_business_concepts
 ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
