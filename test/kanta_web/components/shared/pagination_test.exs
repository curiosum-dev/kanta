defmodule KantaWeb.Components.Shared.PaginationTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest

  alias KantaWeb.Components.Shared.Pagination

  describe "calculate_pages/3" do
    test "returns single page when total_pages is 1" do
      assert Pagination.calculate_pages(1, 1, 4) == [{:page, 1}]
    end

    test "returns all pages when total_pages is less than 2*surrounding+1" do
      assert Pagination.calculate_pages(1, 5, 4) ==
               [{:page, 1}, {:page, 2}, {:page, 3}, {:page, 4}, {:page, 5}]

      assert Pagination.calculate_pages(3, 5, 4) ==
               [{:page, 1}, {:page, 2}, {:page, 3}, {:page, 4}, {:page, 5}]
    end

    test "shows ellipsis when needed for later pages" do
      # 10 pages, current page is 1, surrounding is 2
      # Should show: 1 2 3 4 5 ... 10
      assert Pagination.calculate_pages(1, 10, 2) ==
               [
                 {:page, 1},
                 {:page, 2},
                 {:page, 3},
                 :ellipsis,
                 {:page, 10}
               ]
    end

    test "shows ellipsis when needed for earlier pages" do
      # 10 pages, current page is 8, surrounding is 2
      # Should show: 1 ... 6 7 8 9 10
      assert Pagination.calculate_pages(8, 10, 2) ==
               [
                 {:page, 1},
                 :ellipsis,
                 {:page, 6},
                 {:page, 7},
                 {:page, 8},
                 {:page, 9},
                 {:page, 10}
               ]
    end

    test "shows ellipsis on both sides when in the middle" do
      # 15 pages, current page is 8, surrounding is 2
      # Should show: 1 ... 6 7 8 9 10 ... 15
      assert Pagination.calculate_pages(8, 15, 2) ==
               [
                 {:page, 1},
                 :ellipsis,
                 {:page, 6},
                 {:page, 7},
                 {:page, 8},
                 {:page, 9},
                 {:page, 10},
                 :ellipsis,
                 {:page, 15}
               ]
    end

    test "doesn't add unnecessary ellipsis" do
      # First and last pages are already included
      assert Pagination.calculate_pages(3, 5, 1) ==
               [{:page, 1}, {:page, 2}, {:page, 3}, {:page, 4}, {:page, 5}]

      # When page 2 is shown, don't need ellipsis between 1 and 2
      assert Pagination.calculate_pages(4, 6, 2) ==
               [{:page, 1}, {:page, 2}, {:page, 3}, {:page, 4}, {:page, 5}, {:page, 6}]
    end

    test "when on first page with small surrounding" do
      # 20 pages, current page is 1, surrounding is 1
      # Should show: 1 2 3 ... 20
      assert Pagination.calculate_pages(1, 20, 1) ==
               [{:page, 1}, {:page, 2}, :ellipsis, {:page, 20}]
    end

    test "when on last page with small surrounding" do
      # 20 pages, current page is 20, surrounding is 1
      # Should show: 1 ... 18 19 20
      assert Pagination.calculate_pages(20, 20, 1) ==
               [{:page, 1}, :ellipsis, {:page, 19}, {:page, 20}]
    end
  end

  describe "render/1" do
    test "renders component with all pagination elements" do
      component = &Pagination.render/1

      html =
        render_component(component,
          metadata: %{page_number: 5, total_pages: 10},
          on_page_change: "page-changed",
          surrounding_pages_number: 2
        )

      # Previous button is enabled
      assert html =~ ~r/<button[^>]*phx-value-index="4"[^>]*>.*Previous/s
      refute html =~ ~r/<button[^>]*disabled[^>]*>.*Previous/s

      # Next button is enabled
      assert html =~ ~r/<button[^>]*phx-value-index="6"[^>]*>.*Next/s
      refute html =~ ~r/<button[^>]*disabled[^>]*>.*Next/s

      # Current page has special styling
      assert html =~ ~r/<button[^>]*aria-current="page"[^>]*>\s*5\s*<\/button>/s

      # Check for ellipses
      assert html =~ "…"
    end

    test "disables previous button on first page" do
      html =
        render_component(&Pagination.render/1,
          metadata: %{page_number: 1, total_pages: 10},
          on_page_change: "page-changed"
        )

      # Previous button is disabled
      assert html =~ ~r/<button[^>]*disabled[^>]*>.*Previous/s

      # Next button is enabled
      assert html =~ ~r/<button[^>]*phx-value-index="2"[^>]*>.*Next/s
      refute html =~ ~r/<button[^>]*phx-value-index="2"[^>]*disabled[^>]*>.*Next/s
    end

    test "disables next button on last page" do
      html =
        render_component(&Pagination.render/1, %{
          metadata: %{page_number: 10, total_pages: 10},
          on_page_change: "page-changed"
        })

      # Previous button is enabled
      assert html =~ ~r/<button[^>]*phx-value-index="9"[^>]*>.*Previous/s
      refute html =~ ~r/<button[^>]*phx-value-index="9"[^>]*disabled[^>]*>.*Previous/s

      # Next button is disabled
      assert html =~ ~r/<button[^>]*disabled[^>]*>.*Next/s
    end

    test "renders single page correctly" do
      html =
        render_component(&Pagination.render/1, %{
          metadata: %{page_number: 1, total_pages: 1},
          on_page_change: "page-changed"
        })

      # Both navigation buttons are disabled
      assert html =~ ~r/<button[^>]*disabled[^>]*>.*Previous/s
      assert html =~ ~r/<button[^>]*disabled[^>]*>.*Next/s

      # Only shows page 1
      assert html =~ ~r/<button[^>]*aria-current="page"[^>]*>\s*1\s*<\/button>/s
      refute html =~ ~r/<button[^>]*>\s*2\s*<\/button>/s
    end

    test "sets correct accessibility attributes" do
      html =
        render_component(&Pagination.render/1, %{
          metadata: %{page_number: 5, total_pages: 10},
          on_page_change: "page-changed",
          surrounding_pages_number: 2
        })

      # Check main navigation aria-label
      assert html =~ ~r/<nav aria-label="Pagination"/

      # Check page button aria-labels
      assert html =~ ~r/<button[^>]*aria-label="Page 5"[^>]*aria-current="page"/

      # Check prev/next button aria-labels
      assert html =~ ~r/<button[^>]*aria-label="Previous page"/
      assert html =~ ~r/<button[^>]*aria-label="Next page"/

      # Check ellipsis aria-hidden
      assert html =~ ~r/<span[^>]*aria-hidden="true"[^>]*>…<\/span>/
    end

    test "handles custom surrounding_pages_number" do
      html =
        render_component(&Pagination.render/1, %{
          metadata: %{page_number: 5, total_pages: 15},
          on_page_change: "page-changed",
          surrounding_pages_number: 1
        })

      # Should only show pages 4,5,6 between ellipses
      assert html =~ ~r/<button[^>]*>\s*4\s*<\/button>/s
      assert html =~ ~r/<button[^>]*>\s*5\s*<\/button>/s
      assert html =~ ~r/<button[^>]*>\s*6\s*<\/button>/s
      refute html =~ ~r/<button[^>]*>\s*3\s*<\/button>/s
      refute html =~ ~r/<button[^>]*>\s*7\s*<\/button>/s
    end
  end
end
