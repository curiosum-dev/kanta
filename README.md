<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/curiosum-dev/kanta">
    <img src="./logo.png" alt="Logo" width="110" height="160">
  </a>

  <p align="center">
    User-friendly translations manager for Elixir/Phoenix projects.
    <br />
    <a href="https://github.com/curiosum-dev/kanta/DOCS.md"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="#">View Demo</a>
    ·
    <a href="https://github.com/curiosum-dev/kanta/issues">Report Bug</a>
    ·
    <a href="https://github.com/curiosum-dev/kanta/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

TODO

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

- Elixir/Phoenix project
- Database setup

#### Installation

The package can be installed
by adding `kanta` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kanta, "~> 0.1.0"}
  ]
end
```

#### Add configuration

Add to `config/config.exs` file:

```elixir
# config/config.exs
config :kanta,
  ecto_repo: MyApp.Repo,
  project_root: File.cwd!()
```

Ecto repo is used for translations persistency.

#### Create migration

Create migration with

```bash
mix ecto.gen.migration add_kanta_translations_table
```

Open the generated migration file and set up `up` and `down` functions:

```elixir
defmodule MyApp.Repo.Migrations.AddKantaTranslationsTable do
  use Ecto.Migration

  def up do
    Kanta.Migrations.up()
  end

  def down do
    Kanta.Migrations.down()
  end
end
```

And run

```bash
mix ecto.migrate
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

TO DO

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap

- [ ] Support plural translations
- [ ] Normalize database
- [ ] Add documentation and typespecs

See the [open issues](https://github.com/curiosum-dev/kanta/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. We prefer gitflow and Conventional ommits style but we don't require that. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Artur Ziętkiewicz - artur.zietkiewicz@curiosum.com

Michał Buszkiewicz - michal.buszkiewicz@curiosum.com

Krzysztof Janiec - krzysztof.janiec@curiosum.com

<p align="right">(<a href="#readme-top">back to top</a>)</p>
