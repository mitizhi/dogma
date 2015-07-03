defmodule Dogma.Rules.ModuleNameTest do
  use DogmaTest.Helper

  alias Dogma.Rules.ModuleName
  alias Dogma.Script
  alias Dogma.Error

  def test(script) do
    script |> Script.parse( "foo.ex" ) |> ModuleName.test
  end

  with "a valid module name" do
    setup context do
      script = """
      defmodule HelloWorld do
      end
      """ |> test
      %{ script: script }
    end
    should_register_no_errors
  end

  with "a valid module name as a symbol" do
    setup context do
      script = """
      defmodule :HelloWorld do
      end
      """ |> test
      %{ script: script }
    end
    should_register_no_errors
  end

  with "a valid nested module name" do
    setup context do
      script = """
      defmodule Hello.World do
      end
      """ |> test
      %{ script: script }
    end
    should_register_no_errors
  end

  with "nested modules with valid names" do
    setup context do
      script = """
      defmodule Hello do
        defmodule There do
          defmodule World do
          end
        end
      end
      """ |> test
      %{ script: script }
    end
    should_register_no_errors
  end


  with "a snake_case module name" do
    setup context do
      script = """
      defmodule Snake_case do
      end
      """ |> test
      %{ script: script }
    end
    should_register_errors [
      %Error{
        rule:     ModuleName,
        message:  "Module names should be in CamelCase",
        position: 1,
      }
    ]
  end

  with "a snake_case symbol module name" do
    setup context do
      script = """
      defmodule :snake_case do
      end
      """ |> test
      %{ script: script }
    end
    should_register_errors [
      %Error{
        rule:     ModuleName,
        message:  "Module names should be in CamelCase",
        position: 1,
      }
    ]
  end

  with "a snake_case 2 part module name" do
    setup context do
      script = """
      defmodule Hello.There_world do
      end
      """ |> test
      %{ script: script }
    end
    should_register_errors [
      %Error{
        rule:     ModuleName,
        message:  "Module names should be in CamelCase",
        position: 1,
      }
    ]
  end

  with "a nested snake_case name" do
    setup context do
      script = """
      defmodule Hello do
        defmodule I_am_interrupting do
          defmodule World do
          end
        end
      end
      """ |> test
      %{ script: script }
    end
    should_register_errors [
      %Error{
        rule:     ModuleName,
        message:  "Module names should be in CamelCase",
        position: 2,
      }
    ]
  end


  with "a non-capitalised 2 part name" do
    setup context do
      script = """
      defmodule :"Hello.world" do
      end
      """ |> test
      %{ script: script }
    end
    should_register_errors [
      %Error{
        rule:     ModuleName,
        message:  "Module names should be in CamelCase",
        position: 1,
      }
    ]
  end

end