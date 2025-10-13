defmodule Kanta.Test.Backend do
  @moduledoc false

  use Gettext.Backend,
    otp_app: :test_application,
    priv: "test/fixtures/single_messages"

  def handle_missing_translation(locale, domain, msgctxt, msgid, bindings) do
    send(self(), {locale, domain, msgctxt, msgid, bindings})
    super(locale, domain, msgctxt, msgid, bindings)
  end

  def handle_missing_plural_translation(
        locale,
        domain,
        msgctxt,
        msgid,
        msgid_plural,
        n,
        bindings
      ) do
    send(self(), {locale, domain, msgctxt, msgid, msgid_plural, n, bindings})
    super(locale, domain, msgctxt, msgid, msgid_plural, n, bindings)
  end
end
