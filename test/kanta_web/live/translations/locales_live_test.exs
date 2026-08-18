defmodule KantaWeb.Translations.LocalesLiveTest do
  use ExUnit.Case, async: true

  alias KantaWeb.Translations.LocalesLive

  describe "generate_locale_gradient/1" do
    test "falls back to the default color when colors is nil" do
      assert LocalesLive.generate_locale_gradient(%{colors: nil}) ==
               "background: #{Kanta.Utils.Colors.default_color()};"
    end

    test "falls back to the default color when colors is empty" do
      assert LocalesLive.generate_locale_gradient(%{colors: []}) ==
               "background: #{Kanta.Utils.Colors.default_color()};"
    end

    test "returns a flat background for a single color" do
      assert LocalesLive.generate_locale_gradient(%{colors: ["#123456"]}) ==
               "background: #123456;"
    end

    test "returns a two-color gradient" do
      css = LocalesLive.generate_locale_gradient(%{colors: ["#111111", "#222222"]})

      assert css =~ "linear-gradient"
      assert css =~ "#111111"
      assert css =~ "#222222"
    end

    test "returns a three-color gradient" do
      css =
        LocalesLive.generate_locale_gradient(%{colors: ["#111111", "#222222", "#333333"]})

      assert css =~ "linear-gradient"
      assert css =~ "#111111"
      assert css =~ "#222222"
      assert css =~ "#333333"
    end
  end
end
