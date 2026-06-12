# Development, Testing, and Release Guide

This repository contains two related pieces:

- A Tree-sitter grammar for AutoHotkey v1.
- A Zed extension that packages the grammar, language server, and debug adapter.

For day-to-day development, install the extension directly from this local project folder. Do not push to GitHub just to test in Zed.

Zed dev extension installation has one important detail: the extension folder is local, but the grammar listed in `extension.toml` is checked out through Git using the `[grammars.autohotkey]` `repository` and `rev` fields. For local development, keep that grammar repository as a `file://` URL pointing at this clone. The `rev` must be a local Git commit, but it does not need to be pushed.

## Prerequisites

- Windows
- Node.js 18+
- pnpm or npm
- Rust stable
- Rust target `wasm32-wasip2`
- Zed

Install the Rust target if needed:

```powershell
rustup update stable
rustup target add wasm32-wasip2
```

Install JavaScript dependencies:

```powershell
pnpm install
```

## Common Commands

```powershell
pnpm run generate
pnpm test
cargo test
cargo build --release --target wasm32-wasip2
pnpm run release -- --dry-run
```

Command purpose:

- `pnpm run generate`: regenerates `src/parser.c`, `src/grammar.json`, and `src/node-types.json` from `grammar.js`.
- `pnpm test`: runs Tree-sitter corpus and highlight tests.
- `cargo test`: runs Rust extension unit tests.
- `cargo build --release --target wasm32-wasip2`: verifies the Zed Rust extension can compile.
- `pnpm run release -- --dry-run`: verifies the release build without creating or pushing a tag.

## Install Locally In Zed

Use this workflow when you want the current local project to load in Zed immediately:

```powershell
pnpm install
pnpm run generate
pnpm test

git add grammar.js tree-sitter.json src languages test
git commit -m "fix: local zed grammar"
$rev = git rev-parse HEAD
```

Set `extension.toml` to use this local repository and the commit hash from `$rev`:

```toml
[grammars.autohotkey]
repository = "file:///I:/Github/tree-sitter-autohotkey"
rev = "<local-commit-sha>"
path = "."
```

Then install the dev extension in Zed:

1. Open Command Palette.
2. Run `Extensions: Install Dev Extension`.
3. Select this repository root: `I:\Github\tree-sitter-autohotkey`.
4. Reopen an `.ahk` file.

This is a local-only workflow. No GitHub push is required.

## Local Zed Development Details

Use a local grammar repository while developing:

```toml
[grammars.autohotkey]
repository = "file:///I:/Github/tree-sitter-autohotkey"
rev = "<local-commit-sha>"
path = "."
```

The `rev` must be a real Git commit. Zed will not read uncommitted grammar changes directly.

After changing grammar or query files:

```powershell
pnpm run generate
pnpm test
git add grammar.js tree-sitter.json src languages test
git commit -m "fix: describe grammar change"
$rev = git rev-parse HEAD
```

Update `extension.toml` so `[grammars.autohotkey].rev` equals `$rev`.

Check logs if installation fails:

```powershell
Get-Content "$env:LOCALAPPDATA\Zed\logs\Zed.log" -Tail 200
```

## Local Development Without GitHub

GitHub push is not required for dev installation when using a `file://` grammar repository. Local commit is enough.

You still need a local commit because Zed checks out the grammar by Git revision:

```powershell
git commit -am "fix: local grammar change"
git rev-parse HEAD
```

Use that commit hash in `extension.toml`.

Only push to GitHub when you want another machine, CI, or the public extension release flow to see the change.

Do not change `[grammars.autohotkey].repository` back to GitHub while doing local Zed testing. If it points at GitHub, Zed can only install commits that already exist on GitHub.

## Publishing Setup

Before publishing, switch the grammar repository back from `file://` to the public GitHub repository:

```toml
[grammars.autohotkey]
repository = "https://github.com/CandyTek/tree-sitter-autohotkey"
rev = "<pushed-commit-sha>"
path = "."
```

The `rev` must exist on GitHub:

```powershell
git push origin master
git ls-remote origin <commit-sha>
```

Do not publish a release that points to a local `file://` grammar repository.

## Release Process

1. Run tests:

   ```powershell
   pnpm test
   cargo test
   pnpm run release -- --dry-run
   ```

2. Bump `version` in `extension.toml`.

3. Ensure `[grammars.autohotkey].repository` points to the public GitHub URL and `rev` points to a pushed commit.

4. Commit and push all release changes:

   ```powershell
   git add .
   git commit -m "release: vX.Y.Z"
   git push origin master
   ```

5. Create and push the release tag:

   ```powershell
   pnpm run release
   ```

The release script:

- Reads `version` from `extension.toml`.
- Verifies the Rust extension build.
- Creates tag `vX.Y.Z`.
- Pushes the tag to `origin`.

## Troubleshooting

If Zed reports `failed to fetch revision`, check:

- `extension.toml` has the correct commit hash.
- The commit exists in the repository named by `[grammars.autohotkey].repository`.
- Reinstall the dev extension so Zed re-fetches the grammar checkout.

If Zed reports an injection query error, check:

- `tree-sitter.json` does not reference a missing or invalid `injections.scm`.
- Any injection query contains a required `@content` or `@injection.content` capture.

If Zed reports WASI SDK download or grammar compile issues on Windows:

- Ensure `wasm32-wasip2` is installed with rustup.
- Check `%LOCALAPPDATA%\Zed\extensions\build\wasi-sdk`.
- Delete incomplete `wasi-sdk.tar.gz` downloads and retry.

If the language does not activate after installation:

- Open an `.ahk` file.
- Select `AutoHotkey` manually from the language selector.
- Check `%LOCALAPPDATA%\Zed\logs\Zed.log`.

## Highlight Debugging

When a highlight test fails or `tree-sitter test` starts using extreme memory, work from the smallest reproducible input first.

If you only want the failing cases from the Zed test harness, run `.zed\runtest.ps1` first. It filters out the green rows and makes the remaining mismatch much easier to read.

1. Re-run only the relevant file with `tree-sitter parse`:

   ```powershell
   pnpm exec tree-sitter parse test\highlight\strings.ahk
   pnpm exec tree-sitter parse test\corpus\comments.txt
   ```

2. Use debug output to inspect the exact tree shape and the first `ERROR` / `MISSING` node:

   ```powershell
   pnpm exec tree-sitter parse -d pretty test\highlight\strings.ahk
   ```

3. Trim the sample to the smallest line or two that still fails. For string and command issues, keep the exact punctuation and spacing. AutoHotkey often changes meaning on:

   - `!` before `(...)`
   - `""` inside long quoted strings
   - `%` after commands
   - trailing `;` comments after commands or labels

4. For `Run % ...` and similar force-expression cases, reduce the input in stages:

   - Start with `Run % "foo"`.
   - Add one token class at a time, such as `Chr(34)`, `identifier`, or `(expr)`.
   - If the parse starts dropping the tail of the expression, the issue is usually scanner boundary handling or an overly narrow force-expression rule.
   - Keep a temporary one- or two-line `.ahk` file and compare `tree-sitter parse` output directly against the corpus expectation. That is usually faster than reasoning from the failing diff alone.
   - If the AST is correct but highlighting is wrong, update the query or the highlight test comment lines instead of changing the grammar again.

5. Compare the failing shape with a known-good minimal sample from `test/corpus/`. If the corpus expects one tree shape and the parser produces another, fix the grammar first. If the parser shape is correct but a highlight test still fails, fix the test input or query.

6. Prefer `parse` over `test` while narrowing down the problem. `tree-sitter test` exercises the full harness and can hide the actual parse boundary behind a memory blow-up or timeout.

7. After grammar changes, regenerate and re-check the focused sample before running the full suite:

   ```powershell
   pnpm run generate
   pnpm exec tree-sitter parse test\highlight\strings.ahk
   ```

Practical rules that matter for this repository:

- Keep `grammar.js` as the source of truth. Do not edit generated files by hand.
- If a grammar change affects highlighting, verify the related `test/highlight/*.ahk` file still parses to the intended nodes.
- For `if` / `while` conditions, make sure the new rule does not change the tree shape expected by `test/corpus/control_flow.txt`.
- If `tree-sitter test` fails with a huge memory allocation, check the nearest parse boundary first. A small syntax ambiguity in one line can explode the whole harness.

## Do not read src/parser.c, it just generates file
