# Goose Agent Repo — Example Scaffold

A working example of the Claude-Code-style workflow (per-project context +
an "agents" folder, `install.sh`, push/pull) rebuilt on top of Goose's own
primitives:

| Piece | Goose equivalent |
|---|---|
| `context.md` per project | **`.goosehints`** — auto-loaded project context |
| `agents/` folder | **`recipes/`** folder — reusable YAML agent configs |
| `install.sh` | `install.sh` / `install.ps1` — checks prerequisites, lists recipes |

```
goose-agent-repo/
└── projects/
    └── example-service/
        ├── .goosehints          # project context, like context.md
        ├── install.sh           # bash setup script
        ├── install.ps1          # PowerShell equivalent
        └── recipes/             # this project's "agents"
            ├── code-reviewer.yaml
            └── doc-writer.yaml
```

Add more folders under `projects/` the same way for other repos/projects.

## Workflow

**Publishing a new agent** (same as your current process):
1. Add a new `.yaml` file under the project's `recipes/` folder.
2. Optionally list it in that project's `.goosehints` so Goose (and humans)
   know it exists.
3. Push.

**Using an agent** (after pulling):

```bash
cd projects/example-service
./install.sh                       # or: powershell -File install.ps1
export GOOSE_RECIPE_PATH="$(pwd)/recipes"     # bash/zsh
# $env:GOOSE_RECIPE_PATH = "$PWD\recipes"     # PowerShell

goose run --recipe code-reviewer.yaml --params target_path=./src
goose run --recipe doc-writer.yaml --params target_path=./src/main.py
```

Goose automatically reads `.goosehints` from the working directory, so as
long as you `cd` into the project first, both recipes above pick up its
conventions without you having to repeat them in every prompt.

## What the install scripts actually do

Both scripts perform the same checks (see comments inline for the exact
steps): confirm `goose` is installed, confirm Ollama is reachable, pull
this project's expected model if it isn't already present, and print the
list of recipes available in this project along with the exact commands
to set `GOOSE_RECIPE_PATH` and run one.

They intentionally **don't** try to export environment variables into your
parent shell (a script run as a subprocess can't do that reliably) — they
print the exact command to run yourself, which is copy-paste friendly and
easy to put in a wrapper alias/function if you use this a lot.

## Things to double check against your real Goose version

- `extensions: - type: builtin, name: developer` in both recipes assumes
  Goose's builtin "developer" extension (file + shell tools) is named
  exactly that in your build. Run `goose configure` or check your
  `~/.config/goose/config.yaml` to confirm the exact builtin extension
  names available, and adjust if needed.
- `goose run --recipe <file>.yaml --params key=value` is confirmed CLI
  syntax. Whether an *interactive* session (`goose session start`) accepts
  `--recipe` the same way wasn't confirmed here — check
  `goose session start --help` if you want recipes in interactive mode
  rather than one-shot `goose run`.
- If you'd rather not `git pull` at all, Goose can load recipes straight
  from a GitHub repo via `GOOSE_RECIPE_GITHUB_REPO` (needs `gh` CLI
  authenticated) — worth trying if you want to drop the manual pull step
  entirely.
