defmodule Kanta.Translations.DomainQueries do
  use Kanta.Query,
    module: Kanta.Translations.Domain,
    binding: :domain
end
