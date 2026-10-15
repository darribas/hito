# hito
Provision your linux laptop in one go.

> [/'ito/](https://dictionary.cambridge.org/us/dictionary/spanish-english/hito): _Mojón que se coloca en el camino para delimitar territorios, marcar distancias o dirección_

A git repo of small, standalone bash scripts for provisioning a Fedora + COSMIC
laptop. Each script installs and configures **one** thing. Run them all on a
fresh machine, or run one of them when something needs redoing.

There is no framework, no runner program, no state tracking. The scripts are the
product.

## Install (fresh machine) / update

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/darribas/hito/main/bootstrap.sh)"
```

Use this exact form — **not** `curl ... | bash`. Piping consumes stdin, which
means `sudo` cannot prompt for a password and the run dies on the first
privileged command. The `bash -c "$(...)"` form leaves stdin attached to the
terminal.

`bootstrap.sh` clones the repo to `~/provision` (or updates it if already
present) and runs `all.sh`. It is safe to re-run, so the same command is also
how you update.

## Running things

Everything:

```bash
~/provision/all.sh
```

One thing:

```bash
bash apps/zen/setup.sh
```

There is nothing else to learn — `all.sh` is a `for` loop over
`base/*/setup.sh` then `apps/*/setup.sh`.

## `base/` versus `apps/`

The single criterion is: **does anything else break if this hasn't run?** If
yes, it goes in `base/` (numbered, ordered); if no, it goes in `apps/`
(alphabetical, unordered). This is *not* essential-vs-optional — a daily-driver
app still lives in `apps/` as long as nothing depends on it having run first.

## Why `apps/` isn't numbered

Numeric prefixes are good at ordering and bad at categorising: banded schemes
(`30-49 = desktop apps`) run out and force renumbering. `apps/` has no inherent
order, so it's alphabetical and the directory name does the work — adding the
eleventh app is a non-event and nothing ever gets renumbered.

## Conventions

- **Safe to run twice.** Every script is idempotent: running it a second time
  should change nothing. This is a hard convention, stated in each script's
  comment block, not enforced by code.
- **Scripts repeat themselves on purpose.** There is no `lib/`, no `common.sh`,
  and scripts never source each other. If three scripts need the same four-line
  guard, all three contain it. The point is that any one file can be read — or
  copied into a terminal — and understood completely on its own.

## Testing

Development happens against a Fedora COSMIC Spin VM in virt-manager: revert a
post-install snapshot, run the one-liner (or one script) over SSH, observe,
fix, repeat. Run it twice to check nothing changes the second time. To test an
unmerged branch, prefix the one-liner with `PROVISION_REF=my-branch`.

[TESTING.md](TESTING.md) has the full setup: creating the VM and snapshot,
SSH access, the Docker firewall fix the VM network needs, test loops, and how
to capture a GUI setting as a payload.
