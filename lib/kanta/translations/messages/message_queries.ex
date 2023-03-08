defmodule Kanta.Translations.MessageQueries do
  use Kanta.Query,
    module: Kanta.Translations.Message,
    binding: :message
end
