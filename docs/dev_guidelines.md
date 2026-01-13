# Developer Guidelines: Working with AI Agents 🍻🤖

To ensure a smooth pair-programming experience with AI agents (like Antigravity), follow these configuration steps.

## 1. Disable "Format on Save"
AI agents rely on exact character matching for code edits. If your editor auto-formats the file on every save, it may change the code structure (adding trailing commas, changing indentation) in a way that breaks the agent's ability to locate and modify code blocks.

### VS Code Instructions:
1. Open **Settings** (`Cmd` + `,`).
2. Search for `editor.formatOnSave`.
3. Uncheck the box (or disable it specifically for `[dart]`).

---

## 2. Implement Git Pre-Commit Hooks
Since "Format on Save" is disabled, use a git hook to maintain code quality before every commit.

### Setup (One-time):
Run these commands in your project root:

```bash
touch .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Hook Content:
Add the following to `.git/hooks/pre-commit`:

```bash
#!/bin/sh
echo "Running dart format..."

# Format all files
dart format .

# Re-add files that were changed by the formatter
git add .
```

---

## 3. Communication Strategy
If you find the agent is failing to apply edits, it is likely due to a whitespace mismatch. You can:
1. Manually run `dart format .` to sync the codebase.
2. Tell the agent: "I've formatted the code, please re-read the file before trying again."
