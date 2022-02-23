# asdf-kubectl-kots

[![Build](https://github.com/ganta/asdf-kubectl-kots/actions/workflows/build.yml/badge.svg)](https://github.com/ganta/asdf-kubectl-kots/actions/workflows/build.yml) [![Lint](https://github.com/ganta/asdf-kubectl-kots/actions/workflows/lint.yml/badge.svg)](https://github.com/ganta/asdf-kubectl-kots/actions/workflows/lint.yml)

[Replicated KOTS](https://kots.io/) plugin for the [asdf version manager](https://asdf-vm.com).

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.

# Install

Plugin:

```shell
asdf plugin add kubectl-kots
```

kubectl-kots:

```shell
# Show all installable versions
asdf list-all kubectl-kots

# Install specific version
asdf install kubectl-kots latest

# Set a version globally (on your ~/.tool-versions file)
asdf global kubectl-kots latest

# Now kubectl-kots commands are available
kubectl kots version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/ganta/asdf-kubectl-kots/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Hideki Igarashi](https://github.com/ganta/)
