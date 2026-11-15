#!/usr/bin/env bash
# Configura labels, milestone, proyecto e issues iniciales en GitHub.
# Requisitos: gh instalado y autenticado con permisos de repo y project:
#   gh auth login
#   gh auth refresh -s project
# Uso: bash tools/github/configurar_github.sh [labels|milestone|proyecto|issues|actualizar|todo]
#   actualizar: reescribe el texto de los issues #1..#24 ya creados con
#               tools/github/issues_detalle.md y la columna de dependencias.
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

# Texto detallado del issue N (secciones "=== N ===" de issues_detalle.md)
detalle_de() {
  awk -v n="$1" '
    /^=== [0-9]+ ===$/ { activo = ($2 == n); next }
    activo { print }
  ' "$DIR/issues_detalle.md"
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

# Cuerpo final: texto detallado + sección "Depende de" con números reales
cuerpo_final() {
  local indice="$1" deps="$2"; shift 2
  local cuerpo
  cuerpo="$(detalle_de "$indice")"
  if [ -n "$deps" ]; then
    cuerpo+=$'\n\n## Depende de\n'
    for d in ${deps//,/ }; do
      cuerpo+="- [ ] #${NUMEROS[$d]}"$'\n'
    done
  fi
  cuerpo+=$'\n> Las rutas de archivos del juego (`scenes/`, `scripts/`, `assets/`...) son relativas a la carpeta `game/` (equivalen a `res://` en Godot).\n\nVer docs/REQUISITOS.md y docs/ARQUITECTURA.md.\n'
  printf '%s' "$cuerpo"
}

declare -a NUMEROS
# Filas del backlog cuyo número de issue en GitHub no coincide con su posición
# (los números #25 a #27 los usaron PRs). Formato: [fila]=número_de_issue.
declare -A EXCEPCIONES=([25]=28)

issues() {
  num=$(numero_proyecto || true)
  declare -a dependencias
  i=0
  while IFS=$'\t' read -r titulo etiquetas _desc _criterios deps; do
    [ -z "$titulo" ] && continue
    i=$((i+1))
    url=$(gh issue create --repo "$REPO" --title "$titulo" --label "$etiquetas" \
      --milestone "$MILESTONE" --body "$(detalle_de "$i")")
    echo "$url"
    NUMEROS[$i]="${url##*/}"
    dependencias[$i]="${deps:-}"
    if [ -n "${num:-}" ]; then
      gh project item-add "$num" --owner "$OWNER" --url "$url" >/dev/null
    fi
  done < "$DIR/backlog_zona1.tsv"

  # Segunda pasada: añade "Depende de" con los números reales de GitHub
  for j in $(seq 1 "$i"); do
    gh issue edit "${NUMEROS[$j]}" --repo "$REPO" \
      --body "$(cuerpo_final "$j" "${dependencias[$j]}")" >/dev/null
  done
}

actualizar() {
  # Supone que los issues se crearon en orden (fila N = issue #N), salvo EXCEPCIONES.
  i=0
  declare -a titulos dependencias
  while IFS=$'\t' read -r titulo _etq _desc _criterios deps; do
    [ -z "$titulo" ] && continue
    i=$((i+1))
    titulos[$i]="$titulo"
    dependencias[$i]="${deps:-}"
    NUMEROS[$i]="${EXCEPCIONES[$i]:-$i}"
  done < "$DIR/backlog_zona1.tsv"

  for j in $(seq 1 "$i"); do
    n="${NUMEROS[$j]}"
    actual=$(gh issue view "$n" --repo "$REPO" --json title --jq .title)
    if [ "$actual" != "${titulos[$j]}" ]; then
      echo "Aviso: el issue #$n ('$actual') no coincide con el backlog; se omite."
      continue
    fi
    gh issue edit "$n" --repo "$REPO" \
      --body "$(cuerpo_final "$j" "${dependencias[$j]}")" >/dev/null
    echo "Actualizado #$n"
  done
}

case "${1:-todo}" in
  labels) labels ;;
  milestone) milestone ;;
  proyecto) proyecto ;;
  issues) issues ;;
  actualizar) actualizar ;;
  todo) labels; milestone; proyecto; issues ;;
  *) echo "Uso: $0 [labels|milestone|proyecto|issues|actualizar|todo]"; exit 1 ;;
esac
