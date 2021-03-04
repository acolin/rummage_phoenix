defmodule Rummage.Phoenix.Params do
  def get(opts, defaults) do
    base = opts
           |> merge_params("paginate", defaults)
           |> merge_params("search", defaults)
           |> merge_params("sort", defaults)
           |> merge_params("params", defaults)
           |> convert_to_atom_map()
    Map.put(base, :params, base)
  end

  defp merge_params(opts, type, defaults) do
    key = String.to_atom(type)
    val = Map.get(defaults, key)

    with {:ok, res} <- Map.fetch(opts, type),
         true <- res == %{}
    do
      Map.put(opts, type, val)
    else
      :error -> Map.put(opts, key, val)
      _ -> opts
    end
  end

  defp convert_to_atom_map(map), do: to_atom_map("", map)

  defp to_atom_map(_key, map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      case is_atom(k) do
        true -> {k, to_atom_map(k, v)}
        false -> {String.to_atom(k), to_atom_map(k, v)}
      end
    end)
  end

  defp to_atom_map(k, v) when is_bitstring(v) do
    key = cond do
      is_atom(k) -> Atom.to_string(k)
      true -> k
    end

    to_int = ["page", "per_page", "max_page", "total_count"]
    to_sym = ["search_type", "search_expr", "field", "order"]
    to_str = ["search_term", "name"]
    cond do
      Enum.member?(to_int, key) -> to_integer(v)
      Enum.member?(to_sym, key) -> to_symbol(v)
      Enum.member?(to_str, key) -> to_string(v)
      true -> v
    end
  end

  defp to_atom_map(_k, v), do: v

  defp to_integer(v) when is_number(v), do: v

  defp to_integer(v) when is_bitstring(v) do
    {i, _} = Integer.parse(v)
    i
  end

  defp to_symbol(v) when is_atom(v), do: v
  defp to_symbol(v) when is_bitstring(v), do: String.to_atom(v)
end
