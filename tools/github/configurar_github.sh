#!/usr/bin/env bash
# Configura labels, milestone, proyecto e issues iniciales en GitHub.
# Requisitos: gh instalado y autenticado con permisos de repo y project:
#   gh auth login
#   gh auth refresh -s project
# Uso: bash tools/github/configurar_github.sh [labels|milestone|proyecto|issues|todo]
set -euo pipefail

OWNER="Poke-Guaytambo"
REPO="$OWNER/guaytambo-dex"
MILESTONE="Hito 1 - Zona 1 (avance)"
PROYECTO="Ambato Limpiecito"
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/../.." && pwd)"

numero_proyecto() {
  gh project list --owner "$OWNER" --format json \
    --jq ".projects[] | select(.title==\"$PROYECTO\") | .number"
}

labels() {
  while IFS=$'\t' read -r nombre color desc; do
    [ -z "$nombre" ] && continue
    gh label create "$nombre" --color "$color" --description "$desc" --repo "$REPO" --force
  done < "$ROOT/.github/labels.tsv"
}

milestone() {
  gh api "repos/$REPO/milestones" -f title="$MILESTONE" \
    -f description="Zona 1 funcional para la presentación del avance" >/dev/null
}

proyecto() {
  gh project create --owner "$OWNER" --title "$PROYECTO" >/dev/null
  num=$(numero_proyecto)
  gh project field-create "$num" --owner "$OWNER" --name "Prioridad" --data-type SINGLE_SELECT --single-select-options "Alta,Media,Baja"
  gh project field-create "$num" --owner "$OWNER" --name "Requisito" --data-type TEXT
  gh project field-create "$num" --owner "$OWNER" --name "Zona" --data-type SINGLE_SELECT --single-select-options "Zona 1,Zona 2,Zona 3,Zona 4,Transversal"
  gh project link "$num" --owner "$OWNER" --repo "$REPO"
  echo "Proyecto #$num creado. Configura las vistas desde la web (ver docs/GESTION_PROYECTO.md)."
}

issues() {
  num=$(numero_proyecto || true)
  declare -a numeros cuerpos dependencias
  i=0
  while IFS=$'	' read -r titulo etiquetas descripcion criterios deps; do
    [ -z "$titulo" ] && continue
    i=$((i+1))
    cuerpo=$(printf '## Descripción
%s

## Criterios de aceptación
- [ ] %s

Ver docs/REQUISITOS.md y docs/ARQUITECTURA.md.
' "$descripcion" "$criterios")
    url=$(gh issue create --repo "$REPO" --title "$titulo" --label "$etiquetas" --milestone "$MILESTONE" --body "$cuerpo")
    echo "$url"
    numeros[$i]="${url##*/}"
    cuerpos[$i]="$cuerpo"
    dependencias[$i]="${deps:-}"
    if [ -n "${num:-}" ]; then
      gh project item-add "$num" --owner "$OWNER" --url "$url" >/dev/null
    fi
  done < "$DIR/backlog_zona1.tsv"

  # Segunda pasada: añade "Depende de" con los números reales de GitHub
  for j in $(seq 1 "$i"); do
    [ -z "${dependencias[$j]}" ] && continue
    lista=""
    for d in ${dependencias[$j]//,/ }; do
      lista+="- [ ] #${numeros[$d]}"$'
'
    done
    gh issue edit "${numeros[$j]}" --repo "$REPO"       --body "${cuerpos[$j]}"$'

'"## Depende de"$'
'"$lista" >/dev/null
  done
}

case "${1:-todo}" in
  labels) labels ;;
  milestone) milestone ;;
  proyecto) proyecto ;;
  issues) issues ;;
  todo) labels; milestone; proyecto; issues ;;
  *) echo "Uso: $0 [labels|milestone|proyecto|issues|todo]"; exit 1 ;;
esac
