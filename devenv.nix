{pkgs, ...}: let
  erlang = pkgs.beam.packages.erlangR25;
  nodejs = pkgs.nodejs_20;
  elixir = erlang.elixir_1_14;
  elixir-ls = erlang.elixir-ls.override {elixir = erlang.elixir_1_14;};
in {
  env.LANG = "en_US.UTF-8";
  env.ERL_AFLAGS = "-kernel shell_history enabled";

  enterShell = ''
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export PATH=$PATH:$(pwd)/_build/pip_packages/bin
  '';

  packages =
    (with pkgs; [
      inotify-tools
      alejandra
    ])
    ++ [nodejs elixir-ls];

  languages.elixir = {
    enable = true;
    package = elixir;
  };

  languages.javascript = {
    enable = true;
    package = nodejs;
  };
}
