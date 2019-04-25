defmodule GlobalIdTest do
  use ExUnit.Case

  test "the first id works" do
    id = GlobalId.get_id(0)
    assert id > 0

    {time_segment, node_segment, id_segment} = segments(id)

    assert time_segment > 0
    assert node_segment == GlobalId.node_id()
    assert id_segment == 0
  end

  test "new ids are different" do
    first_id = GlobalId.get_id(0)
    second_id = GlobalId.get_id(first_id)

    assert first_id != second_id

    # make sure it's not a fluke

    third_id = GlobalId.get_id(second_id)

    assert second_id != third_id

    # make sure the segments still look ok

    {time_segment, node_segment, id_segment} = segments(third_id)

    assert time_segment > 0
    assert node_segment == GlobalId.node_id()
    assert id_segment == 2
  end

  test "get ids at maximum rate" do
    first_id = GlobalId.get_id(0)

    1..200_000
    |> Enum.reduce(first_id, fn i, acc ->
      new_global_id = GlobalId.get_id(acc)

      {acc_time, acc_node, acc_id} = segments(acc)
      {new_time, new_node, new_id} = segments(new_global_id)

      assert acc_node == new_node
      assert acc_time <= new_time

      if new_id == 0 do
        assert new_time > acc_time
      else
        assert new_id > acc_id
      end

      # make sure the test does not run too fast
      if rem(i, 1000) == 0 do
        Process.sleep(1)
      end

      new_global_id
    end)
  end

  # split an id into its 3 segments
  @spec segments(non_neg_integer) :: {non_neg_integer, non_neg_integer, non_neg_integer}
  defp segments(id) when is_integer(id) do
    prefix = div(id, 1024)
    id_segment = rem(id, 1024)

    time_segment = div(prefix, 1024)
    node_segment = rem(prefix, 1024)

    {time_segment, node_segment, id_segment}
  end
end
