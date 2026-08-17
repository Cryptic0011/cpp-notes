#!/bin/sh
# Copy C++ notes out of the Obsidian vault, commit, push. GitHub Actions does the rest.
set -e
VAULT="$HOME/Grayson/Graysons Vault/Graysons Vault"
SRC="$VAULT/Things/C++"
REPO="$(cd "$(dirname "$0")" && pwd)"
DEST="$REPO/content/C++"

rm -rf "$DEST"
mkdir -p "$DEST"
rsync -a --exclude '.DS_Store' --exclude '.obsidian' "$SRC/" "$DEST/"

# ponytail: copy only the images the notes actually embed, flat next to them.
# Quartz resolves ![[file.png]] by filename, so no path rewriting needed.
grep -rhoE '!\[\[[^]|]+\.(png|jpe?g|gif|webp|svg)' "$DEST" | sed 's/^!\[\[//' | sort -u |
while IFS= read -r img; do
  found=$(find "$VAULT" -name "$img" -not -path '*/.trash/*' -print -quit)
  [ -n "$found" ] && cp "$found" "$DEST/" || echo "missing image: $img" >&2
done

cd "$REPO"
git add -A content
git diff --cached --quiet && { echo "no changes"; exit 0; }
git commit -q -m "notes: $(date '+%Y-%m-%d %H:%M')"
git push -q
echo "pushed - site rebuilds in ~1 min"
