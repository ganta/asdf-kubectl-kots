# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test kubectl-kots https://github.com/ganta/asdf-kubectl-kots.git "kubectl kots --help"
```

Tests are automatically run in GitHub Actions on push and PR.
