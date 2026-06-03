#!/usr/bin/env bash
set -e

# ─── args ────────────────────────────────────────────────────────────────────

PROJECT_NAME="$1"

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Usage: spec-minded-harness/scripts/init.sh <project-name>"
  echo "Run from your repos folder. Creates ./<project-name>/ with orch and code inside."
  exit 1
fi

# ─── paths ───────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$HARNESS_ROOT/templates"

TARGET_DIR="$(pwd)/$PROJECT_NAME"
ORCH_DIR="$TARGET_DIR/${PROJECT_NAME}-orch"
CODE_DIR="$TARGET_DIR/${PROJECT_NAME}-code"

# ─── guard ───────────────────────────────────────────────────────────────────

if [[ -e "$TARGET_DIR" ]]; then
  echo "Error: '$PROJECT_NAME/' already exists in $(pwd)"
  exit 1
fi

# ─── scaffold ────────────────────────────────────────────────────────────────

mkdir -p "$ORCH_DIR"
mkdir -p "$CODE_DIR/specs/done"

cp "$TEMPLATES_DIR/orch/CLAUDE.md" "$ORCH_DIR/CLAUDE.md"
cp "$TEMPLATES_DIR/orch/.gitignore" "$ORCH_DIR/.gitignore"
cp "$TEMPLATES_DIR/code/CLAUDE.md" "$CODE_DIR/CLAUDE.md"
cp "$TEMPLATES_DIR/code/.gitignore" "$CODE_DIR/.gitignore"

# config.yaml con el nombre del proyecto pre-cargado
sed "s/my-project/$PROJECT_NAME/g" "$HARNESS_ROOT/config.template.yaml" > "$ORCH_DIR/config.yaml"

# ─── done ────────────────────────────────────────────────────────────────────

echo ""
echo "✓ $PROJECT_NAME/"
echo "  ├── ${PROJECT_NAME}-orch/"
echo "  │   ├── CLAUDE.md"
echo "  │   └── config.yaml  ← completá: Trello board ID y path al code repo"
echo "  └── ${PROJECT_NAME}-code/"
echo "      ├── CLAUDE.md"
echo "      └── specs/"
echo ""
echo "Siguiente paso: abrí ${PROJECT_NAME}/${PROJECT_NAME}-orch/ en Claude Code y corré: setup https://trello.com/b/xxxxx/board-name"
