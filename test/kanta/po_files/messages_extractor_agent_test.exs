defmodule Kanta.PoFiles.MessagesExtractorAgentTest do
  use Kanta.Test.DataCase, async: false

  alias Kanta.Config
  alias Kanta.PoFiles.MessagesExtractorAgent
  alias Kanta.PoFiles.Services.StaleDetection

  describe "init/1" do
    test "skips stale detection when disable_stale_detection is true" do
      conf = Config.new(repo: Kanta.Test.Repo, disable_stale_detection: true)

      # Mirrors the real shape the supervisor passes in (`conf.ex` in `lib/kanta.ex`):
      # `{MessagesExtractorAgent, conf: conf, name: Registry.via(...)}`, i.e. a keyword
      # list with more than just `:conf`. A regression test for the bug where `init/1`
      # only matched a 1-key list and silently ignored `disable_stale_detection`.
      assert {:ok, %{stale_detection_result: nil}} =
               MessagesExtractorAgent.init(conf: conf, name: :some_registered_name)
    end

    test "runs stale detection when disable_stale_detection is false" do
      conf = Config.new(repo: Kanta.Test.Repo, disable_stale_detection: false)

      assert {:ok, %{stale_detection_result: %StaleDetection.Result{}}} =
               MessagesExtractorAgent.init(conf: conf, name: :some_registered_name)
    end
  end

  describe "handle_call/3 - {:get_stale_detection_result, false}" do
    test "returns the cached result from state without recalculating" do
      cached_result = %StaleDetection.Result{
        stale_message_ids: MapSet.new([1, 2]),
        fuzzy_matches_map: %{},
        stale_count: 2,
        mergeable_count: 0
      }

      state = %{stale_detection_result: cached_result}

      assert {:reply, ^cached_result, ^state} =
               MessagesExtractorAgent.handle_call(
                 {:get_stale_detection_result, false},
                 {self(), make_ref()},
                 state
               )
    end
  end

  describe "handle_call/3 - {:get_stale_detection_result, true}" do
    # NOTE: this only exercises the branch taken when the *global* `disable_stale_detection`
    # config is `false` (the value the test suite boots with in test_helper.exs). The
    # `disable_stale_detection: true` branch reads `Kanta.config().disable_stale_detection`
    # directly instead of from this GenServer's own state, so it can't be exercised here
    # without either mutating the live, suite-wide `Kanta` registry entry (unsafe — it's
    # shared by every other test) or booting a second named `Kanta` instance (not possible
    # today: `MessagesExtractorAgent.start_link/1` always registers under the literal name
    # `MessagesExtractorAgent`, so a second instance collides with `{:already_started, pid}`
    # on the first one started in test_helper.exs).
    test "recalculates stale detection when disable_stale_detection is false (current global config)" do
      state = %{stale_detection_result: nil}

      assert {:reply, %StaleDetection.Result{} = result, new_state} =
               MessagesExtractorAgent.handle_call(
                 {:get_stale_detection_result, true},
                 {self(), make_ref()},
                 state
               )

      assert new_state.stale_detection_result == result
    end
  end
end
