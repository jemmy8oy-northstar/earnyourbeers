# AI Instructions for Earn Your Beers

This directory contains context and instructions for AI agents working on this project.

## General Guidelines
- **Framework**: .NET (`backend/`) + React (`frontend/`). The Flutter app was retired.
- **Documentation**: Use the `docs/` directory for detailed documentation.
- **Coding Style**: Follow `CLAUDE.md` (StyleCop for C#, ESLint for the frontend).
- **Project Vision**: "Earn Your Beers" is a lighthearted, fun app. Keep the UI vibrant and engaging.

## Specific Rules
- Always update `task.md` and `implementation_plan.md` before making major changes.
- Conversion logic should be centralized and easily configurable.

## Edit Integrity & Self-Correction
- **Perfect Matching**: Ensure `TargetContent` exactly matches the file, including all leading whitespace and newlines. If an edit fails, re-read the file section to verify exact contents.
- **Verification Loop**: After applying a change, check for IDE lint errors and perform a quick `view_file` if the outcome is complex.
- **Granular Edits**: Prefer smaller, focused replacement chunks over large blocks to minimize failure points.
- **State Awareness**: If a file has been modified multiple times in one turn, always use the most recent line numbers from the tool outputs.
- **Auto-Formatting Awareness**: This project uses a Git Pre-Commit hook for formatting instead of "Format on Save". See [dev_guidelines.md](file:///Users/jamesbalenthiran/coding/earn_your_beers/docs/dev_guidelines.md) for details.
