defmodule Whois do
  # 3 retries
  def request(hostname), do: request(hostname, 3)
  def request(hostname, retries) do
    server = server_for(hostname)
    case :gen_tcp.connect(to_char_list(server["host"]), 43, [:binary, active: false], 2000) do
      {:ok, socket} ->
        :ok = :gen_tcp.send(socket, "#{hostname}\r\n")
        {:ok, receive_until_closed(socket)}
      {:error, error} ->
        Mix.shell.info "Retrying #{hostname}"
        case retries do
          0 -> {:error, error}
          _ ->
            :timer.sleep(500)
            request(hostname, retries-1)
        end
    end
  end

  def available?(hostname) do
    server = server_for(hostname)
    case request(hostname) do
      {:ok, msg} -> Regex.match?(Regex.compile!(server["available_pattern"], "i"), msg)
      other -> other
    end
  end

  def server_for(hostname) do
    domain = domain_for(hostname)
    domain.whois_servers |> List.first
  end

  def domain_for(hostname) do
    GenServer.call({:global, :whois_domain_list}, {:domain_for, hostname})
  end

  def domains do
    GenServer.call({:global, :whois_domain_list}, {:domains})
  end

  # Keep receiving from the tcp socket until the socket is closed
  defp receive_until_closed(socket), do: receive_until_closed(socket, "")
  defp receive_until_closed(socket, acc) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, msg} -> receive_until_closed(socket, acc <> msg)
      {:error, :closed} -> acc
    end
  end
end
