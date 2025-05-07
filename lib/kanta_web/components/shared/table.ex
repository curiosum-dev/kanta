defmodule KantaWeb.Components.Shared.Table do
  use Phoenix.Component

  @doc """
  Renders a data table with styling consistent with Kanta's design.

  ## Examples

      <.data_table id="domains-table" rows={@domains} row_click={fn domain -> JS.push("edit_domain", value: %{id: domain.id}) end}>
        <:col label="Name">
          <div class="text-sm font-medium truncate"><%= @item.name %></div>
        </:col>
      </.data_table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  attr :class, :string, default: nil

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def data_table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="bg-base-light dark:bg-base-dark py-6">
      <div class="w-full">
        <div class="flex flex-col">
          <div class="-my-2 overflow-x-auto">
            <div class="py-2 align-middle inline-block min-w-full">
              <div class="shadow overflow-hidden border-b border-slate-200 sm:rounded-lg">
                <table class="min-w-full w-full divide-y divide-slate-200">
                  <thead class="bg-slate-50 dark:bg-stone-900">
                    <tr>
                      <th :for={col <- @col} scope="col" class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-content-light uppercase tracking-wider">
                        <%= col[:label] %>
                      </th>
                      <th :if={@action != []} scope="col" class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-content-light uppercase tracking-wider">
                        <span class="sr-only">Actions</span>
                      </th>
                    </tr>
                  </thead>
                  <tbody
                    id={@id}
                    phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
                    class="bg-white dark:bg-stone-800 divide-y divide-slate-200 dark:divide-accent-dark"
                  >
                    <tr :for={row <- @rows}
                        id={@row_id && @row_id.(row)}
                        class={[@row_click && "cursor-pointer hover:bg-slate-50 hover:dark:bg-base-dark transition-all"]}
                        phx-click={@row_click && @row_click.(row)}>

                      <td :for={col <- @col} class="px-6 py-4">
                        <%= render_slot(col, @row_item.(row)) %>
                      </td>

                      <td :if={@action != []} class="px-6 py-4">
                        <div class="flex items-center justify-end gap-2">
                          <%= for action <- @action do %>
                            <%= render_slot(action, @row_item.(row)) %>
                          <% end %>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
