#!/bin/bash
# Lanza una corrida de la notebook del Grupo B con papermill.
#
# uso:   ./lanzador.sh <semilla> <metodo> <exp> [kaggle]
#        metodo = caso experimental: E2 E2b E3 E4 E5 E6 E7 C3
# ej.:   ./lanzador.sh 278911 E3 6212
#        ./lanzador.sh 278911 E3 6212 TRUE     (modo Kaggle: future 202109)
#
# requisito (una sola vez en la VM):  pip install papermill

set -e

if [ $# -lt 3 ]; then
  echo "uso: $0 <semilla> <metodo> <exp> [kaggle]"
  exit 1
fi

SEMILLA=$1
METODO=$2
EXP=$3
KAGGLE=${4:-FALSE}

# la notebook tiene que estar en la misma carpeta que este script
DIR="$(cd "$(dirname "$0")" && pwd)"
NB="$DIR/WorkFlow_01_junior_grupoB_TS.ipynb"

SALIDA=/content/buckets/b1/exp/notebooks_ejecutadas
mkdir -p "$SALIDA"
OUT="$SALIDA/WF${EXP}_${METODO}_s${SEMILLA}_kaggle${KAGGLE}.ipynb"

echo "$(date '+%F %T')  inicio  metodo=$METODO exp=$EXP semilla=$SEMILLA kaggle=$KAGGLE"

papermill "$NB" "$OUT" -k ir \
  -p semilla "$SEMILLA" \
  -p metodo "$METODO" \
  -p exp "$EXP" \
  -p kaggle "$KAGGLE"

echo "$(date '+%F %T')  fin     metodo=$METODO  ->  $OUT"
