#!/usr/bin/env bash
# Uso (humano o agente): ./scripts/new-post.sh "Título" "resumen" "ia,agentes" < cuerpo.md
set -e; T="$1"; S="$2"; TAGS="$3"
SLUG=$(echo "$T" | iconv -t ascii//TRANSLIT | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9]\+/-/g;s/^-\|-$//g')
F="content/posts/$(date +%F)-$SLUG.md"
{ echo "---"; echo "title: \"$T\""; echo "date: $(date +%F)"; echo "summary: \"$S\""
  echo "tags: [$(echo "$TAGS" | sed 's/,/, /g')]"; echo "---"; echo; cat; } > "$F"
git add "$F" && git commit -m "post: $T" && git push
