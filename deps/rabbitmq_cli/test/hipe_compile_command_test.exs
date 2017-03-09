## The contents of this file are subject to the Mozilla Public License
## Version 1.1 (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License
## at http://www.mozilla.org/MPL/
##
## Software distributed under the License is distributed on an "AS IS"
## basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
## the License for the specific language governing rights and
## limitations under the License.
##
## The Original Code is RabbitMQ.
##
## The Initial Developer of the Original Code is Pivotal Software, Inc.
## Copyright (c) 2016-2017 Pivotal Software, Inc.  All rights reserved.

defmodule HipeCompileCommandTest do
  use ExUnit.Case, async: false
  import TestHelper

  @command RabbitMQ.CLI.Ctl.Commands.HipeCompileCommand
  @vhost   "/"

  setup_all do
    RabbitMQ.CLI.Core.Distribution.start()
    :net_kernel.connect_node(get_rabbit_hostname())

    start_rabbitmq_app()

    on_exit([], fn ->
      :erlang.disconnect_node(get_rabbit_hostname())
    end)
  end

  setup do
    rabbitmq_home = :rabbit_misc.rpc_call(node, :code, :lib_dir, [:rabbit])

    {:ok, opts: %{
      node: get_rabbit_hostname(),
      vhost: @vhost,
      rabbitmq_home: rabbitmq_home
    }}
  end

  test "validate: providing no arguments fails validation", context do
    assert @command.validate([], context[:opts]) ==
      {:validation_failure, :not_enough_args}
  end

  test "validate: providing two arguments fails validation", context do
    assert @command.validate(["/path/one", "/path/two"], context[:opts]) ==
      {:validation_failure, :too_many_args}
  end

  test "validate: providing three arguments fails validation", context do
    assert @command.validate(["/path/one", "/path/two", "/path/three"], context[:opts]) ==
      {:validation_failure, :too_many_args}
  end

  test "validate: providing one directory path and required options succeeds", context do
    assert @command.validate(["/path/one"], context[:opts]) == :ok
  end

  test "validate: failure to load the rabbit application is reported as an error", context do
    assert {:validation_failure, {:unable_to_load_rabbit, _}} =
      @command.validate(["/path/to/beam/files"], Map.delete(context[:opts], :rabbitmq_home))
  end
end
