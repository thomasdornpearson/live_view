defmodule LiveView.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do

    children = [
      worker(Mongo, [[
        name: :mongo,
        verify_peer: false,
        database: "cryptofansonline",
        type: :single,
        ssl: false,
        pool_size: 2,
        url: Application.get_env(:mongodb, :config)[:url],
        ssl_opts: [
          ciphers: ["SCRAM-SHA-256"]
        ],
        timeout: 15000, pool_timeout: 8000,
        connect_timeout: 15000, connect_timeout_ms: 15000
      ]]),
      {Registry, keys: :unique, name: Registry.ViaTest},
      LiveView.ProcessRegistry,
      LiveView.EthereumDataUtils.AverageGas,
      LiveView.EthereumDataUtils.Main,
      # Start the Telemetry supervisor
      LiveViewWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveView.PubSub},
      # Start the Endpoint (http/https)
      LiveViewWeb.Endpoint,
      {Task.Supervisor, name: LiveView.TaskSupervisor},
      # Start a worker by calling: LiveViewTodos.Worker.start_link(arg)
      # {LiveViewTodos.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveView.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LiveViewWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
