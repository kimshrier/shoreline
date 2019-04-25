defmodule GlobalId do
  @moduledoc """
  GlobalId module contains an implementation of a guaranteed globally unique id system.

  The mandate is to generate unique 64 bit ids.  However, after a long enough period
  of time, even with a perfect algorithm, we will eventually run out of ids.  The
  specification does not mention what should happen in that eventuality.

  We can do some analysis to predict when we may run out of ids.  We have a total of
  18,446,744,073,709,552,000 ids, 1024 nodes dispensing ids, and a maximum rate of
  100,000 ids per node per second.  So, each node can hand out 18,014,398,509,481,984
  ids which will take 180,143,985,094 seconds, at the maximum rate.  This is
  approximately 5,708 years.  I will probably be dead, or at least no longer associated
  with this project, so I will let someone else worry about this.  Besides, if you haven't
  updated your software for 5,708 years, I think you have bigger problems than running
  out of ids.

  My solution revolves around partitioning the number space into 3 segments, one for
  the node id, one for the number of millseconds since the epoch, and one for a unique
  value within a time period.

  The node id will take 10 bits out of the 64 bits, leaving us 54.  Allowing for
  100,000 ids per second, and assuming a maximum rate of 1,000 ids per millisecond,
  we can reserve 10 bits to cover that, leaving us 44 bits for milliseconds.  For the
  milliseconds field, the maximum value is 17,592,186,044,416 or roughly 557 years.
  The maximum lifetime of my approach is shorter than a perfect algorithm due to
  it having gaps in the id sequence being handed out.  I still think that 557 years
  will exceed the lifetime of this system.
  """

  # number of milliseconds to subtract the the epoch to extend the lifetime
  # of this software.  Since 1,556,145,831,877 milliseconds have already gone
  # by, this just shifts the time segment closer to now.
  @epoch_offset 1_556_145_831_877

  @doc """
  Please implement the following function.
  64 bit non negative integer output   
  """
  @spec get_id(non_neg_integer) :: non_neg_integer
  def get_id(0) do
    time_segment = timestamp() - @epoch_offset
    node_segment = node_id()
    time_segment * 1024 * 1024 + node_segment * 1024
  end

  def get_id(last_id) do
    prefix = div(last_id, 1024)
    last_id_segment = rem(last_id, 1024)

    if last_id_segment < 1023 do
      prefix * 1024 + last_id_segment + 1
    else
      get_id(0)
    end
  end

  #
  # You are given the following helper functions
  # Presume they are implemented - there is no need to implement them. 
  #

  @doc """
  Returns your node id as an integer.
  It will be greater than or equal to 0 and less than or equal to 1024.
  It is guaranteed to be globally unique. 
  """
  @spec node_id() :: non_neg_integer
  def node_id, do: 511

  @doc """
  Returns timestamp since the epoch in milliseconds. 
  """
  @spec timestamp() :: non_neg_integer
  def timestamp do
    {:ok, now} = DateTime.now("Etc/UTC")
    DateTime.to_unix(now, :millisecond)
  end
end
