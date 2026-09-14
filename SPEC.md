# Build spec: `provision`

A brief for building the first pass of a lean provisioning repo for a Fedora + COSMIC laptop.

**Read §12 before writing anything.** This project is deliberately under-engineered, and the most likely failure mode is adding structure that the spec explicitly rejects.

---

## 1. What this is

A git repo of small, standalone bash scripts. Each one installs and configures one thing. You run them all on a fresh machine, or you run one of them on a working machine when something needs redoing.

There is no framework. There is no runner program, no state tracking, no dependency resolution. The scripts are the product; everything else is a directory listing and a `for` loop.

---

## 2. Governing principle

> **Every line should be a command the user could have typed themselves.**

The repo's second job — after actually provisioning the machine — is to document how the machine was provisioned. That only works if a reader can open one file and understand it completely, without opening a second file to find out what a helper does.

The consequence, which is counterintuitive and must be followed anyway:

**Do not factor out repeated code.** If three scripts need the same four-line guard, all three contain that guard. Repetition is cheap. Indirection is expensive when the file's purpose is to explain itself. There is no `lib/`, no `common.sh`, and scripts never source each other.

A reader should be able to copy any script's body into a terminal and get the same result.

---

## 3. Layout

```
.
├── README.md
├── bootstrap.sh          # curl-installable entry point
├── all.sh                # runs everything
├── base/
│   ├── 00-dnf-conf/setup.sh
│   ├── 01-update/setup.sh
│   ├── 02-rpmfusion/setup.sh
│   └── 03-flathub/setup.sh
└── apps/
    └── zen/
        ├── setup.sh
        └── user.js
```

**Every unit is a directory containing `setup.sh`, plus any files it needs, and nothing else.** This holds in `base/` and `apps/` alike, with no exceptions for units that have no payload.

This is §2's principle applied one level up: a unit should be the complete answer. A parallel `files/` tree breaks that, because understanding `zen/setup.sh` would mean knowing that `files/zen/` exists and holds the other half.

What co-location buys:

- deleting an app is `rm -rf apps/zen`, with no orphaned payload left behind
- renaming is one operation rather than two places that silently drift apart
- a setup can be copied to another repo or handed to someone as a directory
- `HERE` never needs `/..` — a script only ever touches files sitting next to it

The cost is directories that contain a single file. Accepted deliberately. Allowing both shapes would avoid it but forces a judgement call on every new unit and makes the glob two-pronged.

`base/` follows the same shape even though payloads there are rare, because the asymmetry would encode nothing. Base and apps genuinely differ in being ordered versus unordered, and the numbering already expresses that; a shape difference on top carries no further information. One consequence worth having: the `HERE` line is then byte-identical in every script in the repo, which is what you want from boilerplate you are asking people to repeat rather than factor out.

---

## 4. `base/` versus `apps/`

**One criterion: does anything else break if this hasn't run?**

Yes → `base/`. No → `apps/`.

| Script | Why |
|---|---|
| `dnf-conf` | changes how every later `dnf` call behaves |
| `update` | later installs assume a current system |
| `rpmfusion` | packages come from it |
| `flathub` | Flatpak installs fail against the filtered default remote |
| Zen, dictation, Python, COSMIC tweaks | nothing depends on them |

This is **not** "essential vs optional" and **not** "system vs user". Dictation may matter more to the user day-to-day than RPM Fusion does, and it still belongs in `apps/`, because nothing else needs it to have happened first.

Two rules that keep the line from blurring:

- **`base/` stays small.** Five or six scripts. If it grows, something was put there for being *important* rather than for being *depended upon*.
- **A prerequisite only one app needs is not base.** `keyd` setup belongs inside `apps/dictation/`, not ahead of it. `base/` is for what is genuinely shared.

The payoff: anything in `apps/` is independently runnable on any machine where `base/` has run. That satisfies "re-run one thing" through directory layout instead of a dependency mechanism.

---

## 5. Numbering and naming — rationale

Numeric prefixes do two different jobs, and only one of them is worth having.

**Ordering** is real. `dnf-conf` genuinely must precede heavy `dnf` use; repos must precede installs. `base/` is numbered because position carries information there. Gaps are not needed — base is small and rarely changes.

**Categorisation** is cosmetic, and it's the job numbering is bad at. Banded schemes (`30-49 = desktop apps`) run out. When they do, every option is bad: renumber and break every reference in notes and commit messages, spill into the next band and lose the meaning, or start writing `35.5-` and pretend that's fine.

So `apps/` is **not numbered**. It is alphabetical, and names do the work:

- `apps/zen/` says what it is; `apps/30-zen/` says what it is plus a lie about ordering
- adding the eleventh app is a non-event
- nothing ever gets renumbered
- `ls apps/` is a readable inventory

The band instinct comes from `/etc/rc.d` and udev rules, where a single flat directory is imposed and the prefix is the only ordering channel available. This repo has directories. It should use them.

**Naming:** directory names are one word where possible, lowercase, matching what the user calls the thing. `zen/`, `dictation/`, `python/`, `cosmic/`, `docker/`. Not `install-zen/` (everything installs something), not `zen-browser-setup/`. The script inside is always `setup.sh`, in every unit, so the name carries no information and needs none.

---

## 6. Script anatomy

Every script in `base/` and `apps/` follows this shape:

```bash
#!/usr/bin/env bash
#
# Zen browser
#
# Installs Zen from Flathub, applies the user.js prefs, and grants the
# filesystem access it needs for downloads.
#
# Safe to re-run: user.js is overwritten each time. Anything Zen keeps in
# SQLite (workspaces, sidebar layout) is NOT managed here.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZEN_ID="app.zen_browser.zen"

flatpak install -y --noninteractive flathub "$ZEN_ID"
flatpak override --user --filesystem=~/Downloads "$ZEN_ID"

PROFILE=$(find "$HOME/.var/app/$ZEN_ID/.zen" -maxdepth 1 -name '*.Default*' -type d 2>/dev/null | head -1)
if [[ -z "$PROFILE" ]]; then
  echo "No Zen profile yet — launch Zen once, then re-run this script." >&2
  exit 1
fi

install -m 0644 "$HERE/user.js" "$PROFILE/user.js"

echo "MANUAL: sign in to Zen sync"
```

Requirements:

- Shebang, then a comment block: title, what it does, and **an explicit note on re-run behaviour**.
- `set -euo pipefail` after the comment block.
- `HERE` computed from `BASH_SOURCE` so the script works from any working directory and standalone. This line is **identical in every script in the repo** and resolves to the unit's own directory. Payloads are referenced as `"$HERE/thing"`; a script never reaches outside its own directory.
- `sudo` inline, exactly where the user would type it. Never a wrapper.
- Anything requiring a human action is an `echo "MANUAL: ..."` at the end, so the reminder appears when it's relevant. There is no collection mechanism.

---

## 7. Idempotency

**Hard convention: every script must be safe to run twice.** Not enforced by code. Stated in the README, stated in each script's comment block.

Most of it is free:

```bash
sudo dnf install -y <pkg>                          # no-op if present
flatpak install -y --noninteractive flathub <id>   # no-op if present
flatpak remote-add --if-not-exists ...
install -m 0644 src dst                            # overwrites
ln -sfn target link
sudo systemctl enable --now <unit>
rsync -a src/ dst/
```

Three patterns cover the rest. Write them inline, every time:

```bash
# appending to a config file
grep -qxF 'line' "$f" || echo 'line' | sudo tee -a "$f" >/dev/null

# cloning
[[ -d "$dir/.git" ]] || git clone "$url" "$dir"

# curl-pipe installers
command -v thing >/dev/null || curl -fsSL "$url" | bash
```

---

## 8. `all.sh`

The entire runner:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

sudo -v   # cache credentials up front so scripts don't each prompt

for f in base/*/setup.sh apps/*/setup.sh; do
  echo "==> $f"
  bash "$f"
done
```

Stops at the first failure, because `set -e`. No retry, no continue-on-error, no logging framework. If the user wants a log they can redirect.

Running one thing is `bash apps/zen/setup.sh`. There is nothing to learn.

---

## 9. `bootstrap.sh` — curl install

Single entry point for a fresh machine. Lives at the repo root so it has a stable raw URL.

**Invocation form matters.** Document this in the README exactly as:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/bootstrap.sh)"
```

**Not** `curl ... | bash`. Piping consumes stdin, which means `sudo` cannot prompt for a password and the whole run dies on the first privileged command. The `bash -c "$(...)"` form leaves stdin attached to the terminal. This is the single most important detail in this section.

What `bootstrap.sh` does:

1. Refuse to run as root. The scripts use `sudo` inline and expect a normal user with a real `$HOME`.
2. Sanity-check the platform: `/etc/fedora-release` exists. Warn, don't abort, if COSMIC isn't detected — the user may be in a VM or a different session.
3. `command -v git >/dev/null || sudo dnf install -y git`
4. Clone to `$PROVISION_DIR` (default `~/provision`). If it already exists as a git repo, `git pull --ff-only` instead. Honour `$PROVISION_REF` for testing a branch, defaulting to `main`.
5. Print the resolved directory and what is about to run, then prompt for confirmation before invoking `all.sh`.
6. `exec "$PROVISION_DIR/all.sh"`

It must be safe to re-run, which makes it the update path as well as the install path.

Keep it under 60 lines. It is the one script a user runs without having read it, so it should be short enough that reading it first is realistic.

---

## 10. README

Short. It contains:

- the `bash -c "$(curl ...)"` one-liner, with a note on why it isn't `curl | bash`
- how to run a single script
- the `base/` vs `apps/` criterion, in two sentences
- why `apps/` isn't numbered, in two sentences
- the "safe to run twice" convention
- a note that scripts deliberately repeat themselves rather than share helpers

---

## 11. First pass — what to build

1. `README.md`
2. `bootstrap.sh`
3. `all.sh`
4. `base/00-dnf-conf/setup.sh` — `max_parallel_downloads=10`, `fastestmirror=True`, `defaultyes=True` in `/etc/dnf/dnf.conf`, using the `grep -qxF ||` guard
5. `base/01-update/setup.sh` — `sudo dnf upgrade -y`
6. `base/02-rpmfusion/setup.sh` — free and nonfree for the running release, then the codec group
7. `base/03-flathub/setup.sh` — add Flathub if missing, and `flatpak remote-modify --no-filter flathub`, since Fedora ships it filtered and a chunk of apps are otherwise invisible
8. `apps/zen/setup.sh` + `apps/zen/user.js` — an exemplar, establishing the pattern for every later app. A minimal `user.js` with a comment saying what it's for is fine; the user will fill it in.

Note that units 4 through 7 have no payload and so contain a single file each. That is expected; see §3.

Nothing else.

---

## 12. Do not build

Every item here was considered and deliberately rejected. Adding any of them is a regression.

- A runner program with subcommands (`./run list`, `./run show`). `all.sh` and `bash apps/foo/setup.sh` are the interface.
- Stamp files, run-tracking, or "already done" detection.
- Dependency declarations, `AFTER:` headers, or topological sorting. The `base/`-then-`apps/` split *is* the dependency model.
- Structured header metadata intended for machine parsing. The comment blocks are for humans.
- State variables, `--uninstall`, or reversal paths.
- Documentation generation. The scripts are the documentation.
- A shared helper library, sourced functions, or any file scripts source from. See §2.
- A config file, dotenv, or variables file.
- A logging framework, log directories, or timestamped output files.
- A Makefile or justfile wrapping `all.sh`.
- CI, a test suite, or a `tests/` directory. `shellcheck` locally is enough.
- Kickstart files, ISO building, or systemd units.
- Error handling beyond `set -euo pipefail`.

If a script seems to need one of these, the script is probably trying to do too much. Split it or simplify it.

---

## 13. Environment

- **OS:** Fedora 44, COSMIC desktop (Fedora COSMIC Spin)
- **Hardware:** Framework Laptop 13, hostname `dimorphic`
- **Shell:** bash for all scripts, regardless of the user's interactive shell
- **Python:** allowed for genuinely structured work (JSON, TOML, schema-shaped data), standard library only, same comment-block conventions. Not needed in the first pass.
- **Zen Flatpak ID:** `app.zen_browser.zen` — verify with `flatpak list --app` and correct if wrong.
- COSMIC config lives in `~/.config/cosmic/` as many small files. When `apps/cosmic/` is eventually written, it should `rsync -a "$HERE/config/" ~/.config/cosmic/` rather than parse anything. Treat it as a payload, not as declarations.

---

## 14. How this gets tested

A Fedora COSMIC VM with a post-install snapshot. Revert, run, observe, fix, repeat.

The working loop is **write the script first**, run it, fix what breaks. Installing by hand and documenting afterwards reliably loses a step, and the loss isn't discovered until the rebuild.

Idempotency check, worth doing by hand occasionally: run `all.sh` twice in a row. The second run should change nothing.