defmodule Monero.Wallet do
  @moduledoc """
  Operations on Monero wallet RPC. See https://getmonero.org/resources/developer-guides/wallet-rpc.html or
  https://lessless.github.io/#wallet-json-rpc-calls temporarly.
  """

  @doc "Return the wallet's balance."
  @spec getbalance() :: Monero.Operation.Query.t
  def getbalance() do
    request("getbalance")
  end

  @doc "Return the wallet's address."
  @spec getaddress() :: Monero.Operation.Query.t
  def getaddress() do
    request("getaddress")
  end

  @doc """
  Get a list of incoming payments using a given payment id.

  Args:
  * `payment_id` - Payment id of incoming payments.
  """
  @spec get_payments(String.t) :: Monero.Operation.Query.t
  def get_payments(payment_id) do
    request("get_payments", %{payment_id: payment_id})
  end

  @doc """
  Return a list of incoming transfers to the wallet.

  Args:
  * `transfer_type` - may be one of the:
    * `"all"` - for all the transfers.
    * `"available"` - for only transfers which are not yet spent.
    * `"unavailable"` - for only transfers which are already spent.
  """
  @spec incoming_transfers(Strint.t) :: Monero.Operation.Query.t
  def incoming_transfers(transfer_type) do
    request("incoming_transfers", %{transfer_type: transfer_type})
  end

  @doc """
  Create a new wallet. You need to have set the argument `--wallet-dir` when
  launching monero-wallet-rpc to make this work.

  Args:
  * `filename` - Filename for your wallet.
  * `password` - Password for your wallet.
  * `language` - Language for your wallets' seed.
  """
  @spec create_wallet(Strint.t, Strint.t, Strint.t) :: Monero.Operation.Query.t
  def create_wallet(filename, password, language) do
    request("create_wallet", %{filename: filename, password: password, language: language})
  end

  @doc """
  Open a wallet. You need to have set the argument `--wallet-dir` when
  launching monero-wallet-rpc to make this work.

  Args:
  * `filename` - Filename for your wallet.
  * `password` - Password for your wallet.
  """
  @spec open_wallet(Strint.t, Strint.t) :: Monero.Operation.Query.t
  def open_wallet(filename, password) do
    request("open_wallet", %{filename: filename, password: password})
  end

  @type transfer_destination :: %{amount: String.t, address: String.t}

  @type transfer_opts :: {:payment_id, String.t}
    | {:get_tx_key, boolean}
    | {:priority, non_neg_integer}
    | {:do_not_relay, boolean}
    | {:get_tx_hex, boolean}

  @doc """
  Send monero to a number of recipients.

  Args:
  * `destinations` - List of destinations to receive XMR.
  * optional arguments in a form of keyword list as described in the documentation

  **NOTE:** destination amount is in atomic units, means 1e12 = 1 XMR
  """
  @spec transfer([transfer_destination], transfer_opts) :: Monero.Operation.Query.t
  def transfer(destinations, opts \\ []) do
    params =
      opts
      |> build_opts([:payment_id, :get_tx_key, :priority, :do_not_relay, :priority, :ring_size, :unlock_time, :get_tx_hex, :mixin, :unlock_time])
      |> Map.merge(%{destinations: destinations})

    request("transfer", params)
  end
@doc """
  Show information about a transfer to/from this address.

  Args:
  * `txid` - string; Transaction ID used to find the transfer.
  * `account_index` - unsigned int; (Optional) Index of the account to query for the transfer.

  """
  def get_transfer_by_txid(txid, opts \\ []) do
    params =
      opts
      |> build_opts([:account_index])
      |> Map.merge(%{txid: txid})

    request("get_transfer_by_txid", params)
  end

  ## Request
  ######################

  defp request(method, params \\ nil) do
    %Monero.Operation.Query {
      path: "/json_rpc",
      data: %{jsonrpc: "2.0", method: method, params: params},
      service: :wallet,
      parser: &Monero.Wallet.Parser.parse/2
    }
  end

  ## Utils
  ######################

  defp build_opts(opts, permitted), do: opts |> Map.new() |> Map.take(permitted)
end
