defmodule Kanta.Gettext.ExtractorTest do
  @moduledoc """
  Test from `gettext/test/gettext/extractor_test.exs` modified to work with Kanta.Gettext.
  """

  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Gettext.Extractor

  test "extraction process" do
    refute Extractor.extracting?()
    Extractor.enable()
    assert Extractor.extracting?()

    code = """
    defmodule Gettext.ExtractorTest.MyGettext do
      use Gettext.Backend, otp_app: :test_application
    end

    defmodule Gettext.ExtractorTest.MyOtherGettext do
      use Gettext.Backend, otp_app: :test_application, priv: "messages"
    end

    defmodule Foo do
      require Kanta.Gettext.Macros

      def bar do
        Kanta.Gettext.Macros.gettext_comment("some comment")
        Kanta.Gettext.Macros.gettext_comment("some other comment")
        Kanta.Gettext.Macros.gettext_comment("repeated comment")
        Kanta.Gettext.Macros.gettext_with_backend(Gettext.ExtractorTest.MyGettext, "foo")
        Kanta.Gettext.Macros.dngettext_with_backend(Gettext.ExtractorTest.MyGettext, "errors", "one error", "%{count} errors", 2)
        Kanta.Gettext.Macros.dngettext_with_backend(Gettext.ExtractorTest.MyGettext, "errors", "one error", "%{count} errors", 2)
        Kanta.Gettext.Macros.dgettext_with_backend(Gettext.ExtractorTest.MyGettext, "errors", "one error")
        Kanta.Gettext.Macros.gettext_comment("one more comment")
        Kanta.Gettext.Macros.gettext_comment("repeated comment")
        Kanta.Gettext.Macros.gettext_comment("repeated comment")
        Kanta.Gettext.Macros.gettext_with_backend(Gettext.ExtractorTest.MyGettext, "foo")
        Kanta.Gettext.Macros.dgettext_with_backend(Gettext.ExtractorTest.MyOtherGettext, "greetings", "hi")
        Kanta.Gettext.Macros.pgettext_with_backend(Gettext.ExtractorTest.MyGettext, "test", "context based message")
      end
    end
    """

    Code.compile_string(code, Path.join(File.cwd!(), "foo.ex"))

    expected = [
      {"priv/gettext/default.pot",
       ~S"""
       msgid ""
       msgstr ""

       #. some comment
       #. some other comment
       #. repeated comment
       #. one more comment
       #: foo.ex:16
       #: foo.ex:23
       #, elixir-autogen, elixir-format
       msgid "foo"
       msgstr ""

       #: foo.ex:25
       #, elixir-autogen, elixir-format
       msgctxt "test"
       msgid "context based message"
       msgstr ""
       """},
      {"priv/gettext/errors.pot",
       ~S"""
       msgid ""
       msgstr ""

       #: foo.ex:17
       #: foo.ex:18
       #: foo.ex:19
       #, elixir-autogen, elixir-format
       msgid "one error"
       msgid_plural "%{count} errors"
       msgstr[0] ""
       msgstr[1] ""
       """},
      {"messages/greetings.pot",
       ~S"""
       msgid ""
       msgstr ""

       #: foo.ex:24
       #, elixir-autogen, elixir-format
       msgid "hi"
       msgstr ""
       """}
    ]

    # No backends for the unknown app
    assert [] = Extractor.pot_files(:unknown, [])

    pot_files = Extractor.pot_files(:test_application, [])

    dumped =
      pot_files
      |> Enum.reject(&match?({_path, :unchanged}, &1))
      |> Enum.map(fn {k, {:changed, v}} -> {k, IO.iodata_to_binary(v)} end)

    # We check that dumped strings end with the `expected` string because
    # there's the informative comment at the start of each dumped string.
    Enum.each(dumped, fn {path, contents} ->
      {^path, expected_contents} = List.keyfind(expected, path, 0)
      assert String.starts_with?(contents, "## This file is a PO Template file.")
      assert contents =~ expected_contents
    end)
  after
    Extractor.disable()
    refute Extractor.extracting?()
  end

  test "warns on conflicting backends" do
    refute Extractor.extracting?()
    Extractor.enable()
    assert Extractor.extracting?()

    code = """
    defmodule Gettext.ExtractorConflictTest.MyGettext do
      use Gettext.Backend, otp_app: :test_application
    end

    defmodule Gettext.ExtractorConflictTest.MyOtherGettext do
      use Gettext.Backend, otp_app: :test_application
    end

    defmodule FooConflict do
      require Kanta.Gettext.Macros

      def bar do
        Kanta.Gettext.Macros.gettext_with_backend(Gettext.ExtractorConflictTest.MyGettext, "foo")
        Kanta.Gettext.Macros.gettext_with_backend(Gettext.ExtractorConflictTest.MyOtherGettext, "foo")
      end
    end
    """

    assert ExUnit.CaptureIO.capture_io(:stderr, fn ->
             Code.compile_string(code, Path.join(File.cwd!(), "foo_conflict.ex"))
             Extractor.pot_files(:test_application, [])
           end) =~
             "the Gettext backend Gettext.ExtractorConflictTest.MyGettext has the same :priv directory as Gettext.ExtractorConflictTest.MyOtherGettext"
  after
    Extractor.disable()
  end

  test "warns on conflicting plural messages" do
    refute Extractor.extracting?()
    Extractor.enable()
    assert Extractor.extracting?()

    code = """
    defmodule Gettext.ExtractorTest.ConflictingPlural.Gettext do
      use Gettext.Backend, otp_app: :test_conflicting_plural
    end

    defmodule Gettext.ExtractorTest.ConflictingPlural.Foo do
      require Kanta.Gettext.Macros

      def bar do
        Kanta.Gettext.Macros.dngettext_with_backend(Gettext.ExtractorTest.ConflictingPlural.Gettext, "errors", "one error", "%{count} errors", 2)
        Kanta.Gettext.Macros.dngettext_with_backend(Gettext.ExtractorTest.ConflictingPlural.Gettext, "errors", "one error", "multiple errors", 2)
      end
    end
    """

    assert capture_log(fn ->
             Code.compile_string(code, Path.join(File.cwd!(), "foo.ex"))
           end) =~
             """
             Plural message for 'one error' is not matching:
             Using 'multiple errors' instead of '%{count} errors'.
             References: foo.ex:9, foo.ex:10
             """
  after
    Extractor.disable()
  end
end
