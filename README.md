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

## Testing on a fresh VM (GNOME Boxes)

Development happens against a Fedora COSMIC Spin VM in GNOME Boxes, using a
post-install snapshot you revert between runs.

**One-time setup**

1. In Boxes, create a VM from the Fedora COSMIC Spin ISO and complete the
   install.
2. Log in once, reach a COSMIC session, then **shut the VM down** — a snapshot
   taken while powered off reverts more reliably than a live one.
3. Select the VM → **Preferences** (three-dots menu) → **Snapshots** → **＋**.
   Name it `clean-install`.

**Each test run**

1. Boot the VM, open a terminal, and run the one-liner:

   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/darribas/hito/main/bootstrap.sh)"
   ```

   To test an unmerged branch, set the ref:

   ```bash
   PROVISION_REF=my-branch bash -c "$(curl -fsSL https://raw.githubusercontent.com/darribas/hito/main/bootstrap.sh)"
   ```

2. Observe what breaks, fix it in the repo, push, and re-run.

**Revert to a clean machine and retest**

1. Shut the VM down.
2. **Preferences** → **Snapshots** → select `clean-install` → its menu →
   **Revert to this state**.
3. Boot again — you're back to the pristine machine. Repeat the run.

**Idempotency check** — after a successful run, *don't* revert. Just run
`~/provision/all.sh` a second time. Nothing should change.
