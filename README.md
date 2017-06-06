# skycluster

[![Hex.pm Version](http://img.shields.io/hexpm/v/skycluster.svg?style=flat)](https://hex.pm/packages/skycluster)

This library provides a mechanism for automatically forming clusters of Erlang nodes, with
either static or dynamic node membership. It provides a publish/subscribe mechanism for cluster
events so that you can easily be notified when cluster members join or leave, and provides a
pluggable "strategy" system, with multicast UDP gossip, Kubernetes, and EPMD strategies all provided
out of the box.

View the docs [here](https://hexdocs.pm/skycluster).

# Deprecation warning

This package is deprecated in favor of [bitwalker/libcluster](https://github.com/bitwalker/libcluster) implementation for service discovery and [phoenixframework/firenest](https://github.com/phoenixframework/firenest/) for messages broadcasting. 

We think that this approach will be more reusable for community, because separate tasks should be done with a separate building blocks of your application.

## Features

- automatic cluster formation/healing
- choice of multiple clustering strategies out of the box:
  - standard Distributed Erlang facilities (i.e. epmd)
  - multicast UDP gossip, using a configurable port/multicast address,
  - the Kubernetes API, via a configurable pod selector and node basename.
- provide your own clustering strategies (e.g. an EC2 strategy, etc.)
- easy pubsub for cluster events

## Clustering

You have three choices with regards to cluster management. You can use the built-in Erlang tooling for connecting
nodes, by setting `strategy: Cluster.Strategy.Epmd` in the config. If set to `Cluster.Strategy.Gossip` it will make use of
the multicast gossip protocol to dynamically form a cluster. If set to `Cluster.Strategy.Kubernetes`, it will use the
Kubernetes API to query endpoints based on a basename and label selector, using the token and namespace injected into
every pod; once it has a list of endpoints, it uses that list to form a cluster, and keep it up to date.

You can provide your own clustering strategy by setting `strategy: MyApp.Strategy` where `MyApp.Strategy` implements the
`Cluster.Strategy` behaviour, which currently consists of exporting a `start_link/0` callback. You don't necessarily have
to start a process as part of your strategy, but since it's very likely you will need to maintain some state, designing your
strategy as an OTP process (i.e. `GenServer`) is the ideal method, however any valid OTP process will work. `skycluster` starts
the strategy process as part of it's supervision tree.

Currently it's required that strategies connect nodes via the Erlang distribution protocol, i.e. with `Node.connect/1`,
`:net_adm.connect_node/1`, etc. In the future I plan on supporting alternate methods of clustering, but it's still unclear
on how to properly do so.

### Clustering Strategies

The gossip protocol works by multicasting a heartbeat via UDP. The default configuration listens on all host interfaces,
port 45892, and publishes via the multicast address `230.1.1.251`. These parameters can all be changed via the
following config settings:

```elixir
config :skycluster,
  strategy: {:system, :atom, LIBCLUSTER_STRATEGY, Cluster.Strategy.Gossip},
  port: {:system, :integer, LIBCLUSTER_MULTICAST_PORT, 45892},
  if_addr: {:system, LIBCLUSTER_MULTICAST_PORT_IF_ADDR, {0,0,0,0}},
  multicast_addr: {:system, LIBCLUSTER_MULTICAST_ADDR, {230,1,1,251}},
  # a TTL of 1 remains on the local network,
  # use this to change the number of jumps the
  # multicast packets will make
  multicast_ttl: {:system, :integer, LIBCLUSTER_MULTICAST_TTL, 1}
```

The Kubernetes strategy works by querying the Kubernetes API for all endpoints in the same namespace which match the provided
selector, and getting the container IPs associated with them. Once all of the matching IPs have been found, it will attempt to
establish node connections using the format `<kubernetes_node_basename>@<endpoint ip>`. You must make sure that your nodes are
configured to use longnames, that the hostname matches the `kubernetes_node_basename` setting, and that the domain matches the
IP address. Configuration might look like so:

```elixir
config :skycluster,
  strategy: { :system, "LIBCLUSTER_STRATEGY", Cluster.Strategy.Kubernetes },
  kubernetes_selector: { :system, "LIBCLUSTER_KUBERNETES_SELECTOR", "app=my_app" },
  kubernetes_node_basename: { :system, "LIBCLUSTER_KUBERNETES_NODE_BASENAME", "my_app" }
```

And in vm.args:

```
-name myapp@10.128.0.9
-setcookie test
```

## Cluster Events

You can subscribe/unsubscribe a process to cluster events with `Cluster.Events.subscribe(pid)` and
`cluster.Events.unsubscribe(pid)`. Currently, only two events are published to subscribers:

- `{:nodeup, node}` - when a node is connected, the node name is an atom
- `{:nodedown, node}` - same as above, but occurs when a node is disconnected

Events are sent to subscribers with `Kernel.send/2`, so if subscribing a `gen_*` process, you'll receive
them via the `handle_info/2` callback.

## License

MIT
