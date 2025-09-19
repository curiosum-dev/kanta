# Contributing to Kanta

Thank you for your interest in contributing to Kanta! This document provides guidelines and information for contributors.

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting started

### Development environment

#### Prerequisites

* Elixir 1.14+ and OTP 24+
  - _If implementing a proposed feature requires bumping Elixir or OTP, we're open to considering that._
* PostgreSQL (for database-related work)
* Git

Developing and testing Kanta requires a database as it stores translation data in Ecto schemas. The library integrates closely with Phoenix LiveView for the web interface.

#### Setup

Just clone the repository, install dependencies normally, develop and run tests and static checks according to the [workflow file](.github/workflows/development.yml).

## How to contribute

### Before proceeding: where to discuss things?

The best place to discuss fresh ideas for the library's future and ask any sorts of questions (not strictly constituting an issue as defined below) is the [Kanta Slack channel][0]. You can also use [GitHub Discussions][1].

For example, if you've got a general question about Kanta's development direction, or about its intended behaviour in a specific translation management scenario, it's more convenient to start a discussion on Slack or GitHub than to file an issue right away.

However, if there's clearly a bug you'd like to report, or you have a specific feature idea that you'd like to explain, it's perfect material for a GitHub issue inside the project!

### Reporting issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue templates** when available
3. **For bug reports, provide detailed information**:
   - Elixir/OTP/Phoenix versions
   - Kanta version
   - Database type (PostgreSQL or other)
   - Minimal reproduction case
   - Expected vs actual behavior
   - Translation-related context (locales, domains, etc.)
4. **For feature requests, check against roadmap outlined in [README](./README.md) and provide the following**:
   - Purpose of the new feature
   - Intended usage in translation workflows
   - Expected implementation complexity (if possible to gauge)
   - Expected impact on existing translation features and backward compatibility

### Pull requests

#### Before you start

- **Check existing PRs** to avoid duplicate work
- **Open an issue** for discussion on significant changes (we follow the 1 issue <-> 1 PR principle)
- **Follow our coding standards** (see below)

#### PR process

1. **Fork the repository** and create a feature branch
2. **Make your changes** with clear, focused commits
3. **Add tests** for new functionality
4. **Update documentation** as needed, including README
5. **Run the full test suite** as well as all static checks
6. **Submit your PR** with a clear description

#### PR Requirements

- [ ] Code compiles without warnings (`mix compile --warnings-as-errors`)
- [ ] Tests pass (`mix test`)
  - _Includes added tests to new features and fixed bugs._
  - _Tests pass for all combinations of tool versions covered by the CI matrix (see `.github/workflows/development.yml`)._
- [ ] Code follows style guidelines (`MIX_ENV=test mix credo`)
  - _Run Credo in test environment to ensure tests and support code adheres to style rules as well._
- [ ] Types are correct (`MIX_ENV=test mix dialyzer`)
  - _Run Credo in test environment to ensure tests and support code has correct typing as well._
  - _Precise typing is encouraged for all newly added modules and functions._
  - _Ignores are permitted with an inline comment with proper justification._
- [ ] Documentation is updated: a bare minimum is updates to affected public API parts
  - _Functions intended for usage by application code must have descriptions of arguments, purpose, and usage examples._
  - _For crucial additions to features, README must also be updated._
- [ ] Commit messages are clear and descriptive
  - If already used throughout commit history, use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
  - Otherwise, use single-line messages formatted as: `Commit purpose in imperative mode [#issue_number]`.
    - Focus on what vs how, and keep it simple
    - Example: `Fix incorrect action definition issue [#123]`

## Development guidelines

### Code style

We use [Credo](https://github.com/rrrene/credo) for code analysis:

```bash
MIX_ENV=test mix credo
```

Key principles:
- **Clarity over cleverness** - write readable code that's easy to understand and consume for translation management workflows. Use macros wisely and only when needed.
* **Focused dependencies** - Kanta relies on Phoenix LiveView for the UI, Ecto for data persistence, and Gettext for translation management. New dependencies should be justified and align with the translation management scope.
- **Follow Elixir/Phoenix conventions** - use standard patterns and don't fight the platform. Avoid [common Elixir anti-patterns](https://hexdocs.pm/elixir/what-anti-patterns.html). Write functional, idiomatic Elixir code that integrates well with Phoenix applications.
- **Document public APIs** - include `@doc` and `@moduledoc` extensively. Avoid `@moduledoc false` unless a module is deeply private. Type extensively with `@spec`, use `Kanta.Types` where applicable, and avoid vague types like `map()`, `any()`, or `term()` where possible.
- **Handle errors gracefully** - consider correct error propagation and follow Phoenix/LiveView conventions for error handling in the UI components.

### Testing

- **Write tests for all new functionality and bug fixes**
- **Maintain high test coverage**
- **Use descriptive test names**
- **Test both success and failure cases**

### Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format if already used in the repository. Otherwise, write single-line messages in imperative mode and mark related issue number with [#number].

### Branching Strategy

Follow [Conventional Branch](https://conventional-branch.github.io/) format if already used in the repository. Otherwise, use `issue_number-issue_name` as branch names. Create feature branches off `main` or `master` and avoid a nested branch tree.

## Release Process

Releases are handled by maintainers:

1. Version bump in `mix.exs`
2. Update `CHANGELOG.md`
3. Create GitHub release
4. Publish to Hex.pm

## Community

### Getting help

- [Kanta Slack channel][0] - for chat, questions and general discussion
- [GitHub Discussions][1] - for questions and general discussion
- [GitHub Issues][2] - for bug reports and feature requests
- [Curiosum Blog][4] - for updates, tutorials and other content

### Recognition

We are eager to publicly recognize your valuable input as a Kanta contributor! Your contributions will be highlighted in subsequent release notes, as well as blog posts announcing community contributions.

## Questions?

Feel free to:
- Join us on [Kanta Slack][0]
- Open a [GitHub Discussion](https://github.com/curiosum-dev/kanta/discussions)
- Contact us at [Curiosum](https://curiosum.com/contact)
- Check our [blog](https://curiosum.com/blog?search=kanta) for updates

Thank you for contributing to Kanta! 🎉

[0]: https://elixir-lang.slack.com/archives/C099BMEN5BP
[1]: https://github.com/curiosum-dev/kanta/discussions
[2]: https://github.com/curiosum-dev/kanta/issues
[4]: https://curiosum.com/blog?search=kanta
