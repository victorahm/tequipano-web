# Contributing

Thanks for your interest in Tequipano-Web. Contributions are welcome.

## Getting started

1. Fork the repository and clone your fork.
2. Open the project in a DevContainer, or install Ruby 4.0.7 and PostgreSQL 18 locally.
3. Run `bundle install` and `bin/setup`.
4. Start the app with `mise run server` and visit `http://localhost:3000`.

## Before opening a pull request

Run the same checks as CI:

```bash
mise run test       # bin/rails test
mise run lint       # bin/rubocop
bin/brakeman -q -w3 # security scan
bin/bundler-audit   # vulnerable gem check
bin/importmap audit # JavaScript dependency audit
```

All GitHub Actions checks must pass before a pull request can be merged.
Keep changes focused, add tests for new behavior, and update the README when
you change setup instructions or public APIs.

## Security issues

Do not report security vulnerabilities in public issues. See [SECURITY.md](SECURITY.md).

## License

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
