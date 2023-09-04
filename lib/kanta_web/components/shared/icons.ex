defmodule KantaWeb.Components.Icons do
  @moduledoc """
  SVG icons used in Kanta UI
  """

  use Phoenix.Component

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
end
