import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";

const dryRun = process.argv.includes("--dry-run");

function run(command, args, options = {}) {
  return execFileSync(command, args, {
    encoding: "utf8",
    stdio: options.stdio ?? "pipe",
  });
}

function output(command, args) {
  return run(command, args).trim();
}

const extensionToml = readFileSync("extension.toml", "utf8");
const versionMatch = extensionToml.match(/^version\s*=\s*"([^"]+)"/m);

if (!versionMatch) {
  console.error('Error: Could not find version = "..." in extension.toml');
  process.exit(1);
}

const tag = `v${versionMatch[1]}`;
const head = output("git", ["rev-parse", "HEAD"]);
const status = output("git", ["status", "--porcelain"]);

if (status && !dryRun) {
  console.error("Error: Worktree has uncommitted changes. Commit before releasing.");
  process.exit(1);
}

try {
  const tagCommit = output("git", ["rev-parse", "-q", "--verify", `refs/tags/${tag}`]);
  if (tagCommit !== head) {
    console.error(
      `Error: Tag ${tag} already exists at ${tagCommit}, but HEAD is ${head}. Bump extension.toml version before releasing.`,
    );
    process.exit(1);
  }
} catch {
  // Missing tag is the expected path.
}

console.log("Verifying Rust extension build...");
run("cargo", ["build", "--release", "--target", "wasm32-wasip2"], {
  stdio: "inherit",
});

if (dryRun) {
  console.log(`Dry run complete. ${tag} was not created or pushed.`);
  process.exit(0);
}

console.log(`Creating tag ${tag}...`);
try {
  run("git", ["rev-parse", "-q", "--verify", `refs/tags/${tag}`]);
  console.log(`Tag ${tag} already exists locally at HEAD.`);
} catch {
  run("git", ["tag", tag], { stdio: "inherit" });
}
run("git", ["push", "origin", tag], { stdio: "inherit" });
console.log(`Done! Tag ${tag} pushed. GitHub Action will create release and PR.`);
