defmodule Whois.DomainList do
  use GenServer

  @initial_state %{domains: []}

  def handle_call({:domain_for, hostname}, _from, %{domains: domains} = state) do
    domain = Enum.max_by(domains, fn(domain) ->
      if Regex.match?(~r/\.#{domain.name}$/, hostname) do
        String.length(domain.name)
      else
        0
      end
    end)
    {:reply, domain, state}
  end

  def handle_call({:domains}, _from, %{domains: domains} = state) do
    {:reply, domains, state}
  end

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state, name: {:global, :whois_domain_list})
  end

  def init(state) do
    {:ok, %{state | domains: load_domains}}
  end

  defp load_domains do
    {:ok, json} = Application.get_env(:whois, :domains_file)
    |> File.read

    Poison.decode!(json, as: [%Whois.Domain{}])
  end
end
