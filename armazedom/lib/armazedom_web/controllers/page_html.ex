defmodule ArmazedomWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use ArmazedomWeb, :html
  use PhoenixHTMLHelpers

  embed_templates "page_html/*"

  defp period_to_name(period) do
    case period do
      15 -> "Quinzenal"
      30 -> "Mensal"
      90 -> "Trimestral"
      180 -> "Semestral"
      365 -> "Anual"
      _ -> "Período desconhecido"
    end
  end
end
