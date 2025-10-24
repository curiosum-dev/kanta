defmodule KantaWeb.Components.Icons do
  @moduledoc """
  SVG icons used in Kanta UI
  """

  use Phoenix.Component

  def replace do
    """
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-replace-icon lucide-replace"><path d="M14 4a1 1 0 0 1 1-1"/><path d="M15 10a1 1 0 0 1-1-1"/><path d="M21 4a1 1 0 0 0-1-1"/><path d="M21 9a1 1 0 0 1-1 1"/><path d="m3 7 3 3 3-3"/><path d="M6 10V5a2 2 0 0 1 2-2h2"/><rect x="3" y="14" width="7" height="7" rx="1"/></svg>
    """
    |> Phoenix.HTML.raw()
  end

  def arrow_left(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <line x1="19" y1="12" x2="5" y2="12" />
    <polyline points="12 19 5 12 12 5" />
    </svg>
    """
  end

  def arrow_right(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <line x1="5" y1="12" x2="19" y2="12" />
    <polyline points="12 5 19 12 12 19" />
    </svg>
    """
  end

  def search(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <circle cx="11" cy="11" r="8" />
    <line x1="21" y1="21" x2="16.65" y2="16.65" />
    </svg>
    """
  end

  def chevrons_up_down(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    width="24"
    height="24"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <path d="M7 15l5 5 5-5" />
    <path d="M7 9l5-5 5 5" />
    </svg>
    """
  end

  def inspect(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <path d="M19 11V4a2 2 0 00-2-2H4a2 2 0 00-2 2v13a2 2 0 002 2h7" />
    <path d="M12 12l4.166 10 1.48-4.355L22 16.166 12 12z" />
    <path d="M18 18l3 3" />
    </svg>
    """
  end

  def languages(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <path d="M5 8l6 6" />
    <path d="M4 14l6-6 2-3" />
    <path d="M2 5h12" />
    <path d="M7 2h1" />
    <path d="M22 22l-5-10-5 10" />
    <path d="M14 18h6" />
    </svg>
    """
  end

  def album(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
    <polyline points="11 3 11 11 14 8 17 11 17 3" />
    </svg>
    """
  end

  def box(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z" />
    <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
    <line x1="12" y1="22.08" x2="12" y2="12" />
    </svg>
    """
  end

  def menu(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <line x1="4" y1="12" x2="20" y2="12" />
    <line x1="4" y1="6" x2="20" y2="6" />
    <line x1="4" y1="18" x2="20" y2="18" />
    </svg>
    """
  end

  def moon(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" />
    </svg>
    """
  end

  def computer(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    >
    <path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 0 1-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0 1 15 18.257V17.25m6-12V15a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 15V5.25m18 0A2.25 2.25 0 0 0 18.75 3H5.25A2.25 2.25 0 0 0 3 5.25m18 0V12a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 12V5.25"></path>
    </svg>

    """
  end

  def chevron_left(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 20 20"
    fill="currentColor"
    >
    <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
    </svg>
    """
  end

  def chevron_right(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 20 20"
    fill="currentColor"
    >
    <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
    </svg>
    """
  end

  def trash(assigns) do
    attrs = assigns_to_attributes(assigns)
    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <svg {@attrs}
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="currentColor"
    >
    <path d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
    </svg>
    """
  end
end
