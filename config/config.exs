# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :skycluster,
  strategy: Cluster.Strategy.Epmd
