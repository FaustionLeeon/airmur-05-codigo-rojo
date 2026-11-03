#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
from pathlib import Path

root = Path('.')
indexes05 = sorted(root.glob('airmur-05/*/index.json'))
indexes06 = sorted(root.glob('airmur-06/*/index.json'))
indexes = indexes05 + indexes06
assert len(indexes05) == 6, f'se esperaban 6 escenarios de AIRMUR 05 y hay {len(indexes05)}'
assert len(indexes06) == 6, f'se esperaban 6 escenarios de AIRMUR 06 y hay {len(indexes06)}'

structure = json.loads((root / 'structure.json').read_text())
assert structure == {'items': [
    {'path': 'airmur-05', 'title': 'AIRMUR 05 — CÓDIGO ROJO'},
    {'path': 'airmur-06', 'title': 'AIRMUR 06 — OPERACIÓN PUENTE'},
]}

for index in indexes:
    data = json.loads(index.read_text())
    assert data.get('backend', {}).get('imageid') == 'ubuntu', index
    details = data['details']
    refs = []
    for section in (details['intro'], details['finish']):
        refs.extend(section.get(k) for k in ('text', 'foreground', 'background') if section.get(k))
    steps = details['steps']
    assert len(steps) == 3, f'{index}: se esperaban 3 pasos'
    verifies = [s.get('verify') for s in steps if s.get('verify')]
    assert len(verifies) == 1, f'{index}: debe haber un verify por misión'
    for step in steps:
        refs.extend(step.get(k) for k in ('text', 'foreground', 'background', 'verify') if step.get(k))
    for ref in refs:
        target = index.parent / ref
        assert target.is_file(), f'{index}: falta {ref}'
    assert (index.parent / 'setup.sh').is_file(), f'{index}: falta setup.sh'

norm = (root / 'docs/NORMATIVA_RA5.md').read_text()
for letter in 'abcdef':
    assert f'> {letter})' in norm, f'falta CE 5.{letter}'
norm6 = (root / 'docs/NORMATIVA_RA6.md').read_text()
for letter in 'abcdefghi':
    assert f'> {letter})' in norm6, f'falta CE 6.{letter}'
matrix6 = (root / 'docs/MATRIZ_RA6_CE.md').read_text()
for letter in 'abcdefghi':
    assert f'6.{letter}' in matrix6, f'falta 6.{letter} en la matriz'
print(f'JSON y referencias: OK ({len(indexes)} escenarios)')
PY

while IFS= read -r -d '' script; do
  bash -n "$script"
  [ -x "$script" ] || { echo "No ejecutable: $script" >&2; exit 1; }
done < <(find . -type f -name '*.sh' -print0)

if grep -RInE 'backend.*(ssh|systemd)|imageid.*[^u]buntu' airmur-05 airmur-06 --include='index.json'; then
  echo 'Se encontró un backend no permitido' >&2
  exit 1
fi

echo 'Sintaxis shell y permisos: OK'
echo 'VALIDACIÓN ESTÁTICA SUPERADA'
