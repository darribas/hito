---
name: manage-apps
description: Add or remove a provisioning unit in the hito repo — an app under apps/, or (rarely) a base/ unit. Use whenever the user wants to add, install, set up, wire in, remove, or delete a tool/app from this provisioning repo, or asks where a new setup.sh should live and how to make it fit. Enforces the repo's conventions: one self-contained directory per unit, deliberate repetition over shared helpers, and idempotent scripts.
---

# Managing provisioning units

This repo is a set of small, standalone bash scripts, one per thing installed.
There is no framework, runner, or shared library — see `SPEC.md` for the full
rationale. Your job when adding or removing a unit is to keep it that way.

**Non-negotiable conventions (violating any of these is a regression):**

- Every unit is a **directory containing `setup.sh`** plus any files it needs,
  and nothing else. This holds even when the unit has no payload (a
  single-file directory is expected and fine).
- **Do not factor out repeated code.** No `lib/`, no `common.sh`, scripts never
  source each other. If a guard is repeated across scripts, repeat it. A reader
  must be able to understand — and paste into a terminal — any one file alone.
- Payloads live **next to** the script and are referenced as `"$HERE/thing"`. A
  script never reaches outside its own directory. There is no parallel `files/`
  tree.
- Every script is **safe to run twice.** Idempotency is a hard convention.
- `sudo` goes **inline**, exactly where the user would type it — never a wrapper.
- Anything needing a human is an `echo "MANUAL: ..."` at the **end** of the
  script.

Before doing anything, skim `SPEC.md` §2–§7 and §12 so your change matches the
existing scripts in tone and shape.

## Adding a unit

### 1. Decide `base/` or `apps/`

One criterion: **does anything else break if this hasn't run?**

- **Yes → `base/`.** It's a genuine prerequisite something else depends on
  (e.g. a repo that packages come from). `base/` stays small — five or six
  units. A prerequisite that only *one* app needs is **not** base; it belongs
  inside that app's directory.
- **No → `apps/`.** This is the default. Note this is *not* essential-vs-optional:
  a daily-driver app still goes in `apps/` as long as nothing depends on it
  having run first.

If in doubt, it's `apps/`.

### 2. Name the directory

One word where possible, lowercase, matching what the user calls the thing:
`zen/`, `dictation/`, `python/`, `docker/`. Not `install-zen/` (everything
installs something), not `zen-browser-setup/`. `apps/` is alphabetical and
**not numbered** — just create `apps/<name>/`. `base/` units carry a numeric
prefix because order matters there; pick the next number (or slot it where its
ordering demands) e.g. `base/04-<name>/`.

### 3. Create `apps/<name>/setup.sh`

Use this skeleton and fill it in. The header comment and the `HERE` line are
required in every script; the `HERE` line is byte-identical everywhere.

```bash
#!/usr/bin/env bash
#
# <Title>
#
# <What it does, in a sentence or two, and why it matters.>
#
# Safe to re-run: <state exactly what happens on a second run — what is
# overwritten, what is left alone.>

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ... the commands, sudo inline where needed ...

echo "MANUAL: <any human step>"   # only if there is one
```

The comment block's re-run note is not optional — write the honest behaviour.

### 4. Make it idempotent

Most tools give idempotency for free:

```bash
sudo dnf install -y <pkg>                          # no-op if present
flatpak install -y --noninteractive flathub <id>   # no-op if present
flatpak remote-add --if-not-exists ...
install -m 0644 src dst                            # overwrites
ln -sfn target link
sudo systemctl enable --now <unit>
rsync -a src/ dst/
```

For the rest, write these guards inline (every time — do not extract them):

```bash
# appending to a config file
grep -qxF 'line' "$f" || echo 'line' | sudo tee -a "$f" >/dev/null

# cloning
[[ -d "$dir/.git" ]] || git clone "$url" "$dir"

# curl-pipe installers
command -v thing >/dev/null || curl -fsSL "$url" | bash
```

If an operation isn't naturally idempotent (e.g. `dnf swap`), guard it with a
check so the second run is a no-op — see `base/02-rpmfusion/setup.sh` for an
`rpm -q ... ||` example.

### 5. Add payloads next to the script

Config files, `user.js`, a `config/` dir to rsync — all go in `apps/<name>/`
and are referenced as `"$HERE/..."`. See `apps/zen/` (a `user.js` copied with
`install -m 0644 "$HERE/user.js" ...`) for the pattern.

### 6. Do NOT wire it into `all.sh`

`all.sh` globs `base/*/setup.sh apps/*/setup.sh`. A new directory is picked up
automatically. There is nothing to register.

### 7. Verify

- `bash -n apps/<name>/setup.sh` and `shellcheck apps/<name>/setup.sh`.
- On the Fedora COSMIC VM: run it once, then run it again — the second run must
  change nothing (see the testing section of `README.md`).

## Removing a unit

1. Confirm it's in `apps/` (safe) rather than `base/` (something may depend on
   it — check before removing, and reconsider whether callers break).
2. `rm -rf apps/<name>`. That's the whole operation: co-location means the
   payload goes with it, and there are no orphaned files.
3. There is **nothing else to clean** — no runner entry, no stamp/state file,
   no dependency list, no docs to regenerate. If you find yourself hunting for
   other places to update, stop: the repo has none by design.
4. Note that removal only stops the repo from *re-provisioning* the thing; it
   does not uninstall it from a machine (there are no reversal paths — §12).
   If the user wants it gone from their machine too, tell them the manual
   uninstall command (e.g. `flatpak uninstall <id>`), but don't add it to the
   repo.

## Do not add

While managing units, never introduce any of the things `SPEC.md` §12 rejects:
a runner with subcommands, stamp/state files, dependency headers or sorting,
machine-parseable metadata, `--uninstall` paths, a shared helper library, a
config/dotenv file, a logging framework, or a Makefile. If a unit seems to need
one of these, it's trying to do too much — split it or simplify it.
