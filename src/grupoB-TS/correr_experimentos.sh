#!/bin/bash
# Corre todos los casos del Grupo B con las 5 semillas.
# La primera semilla de cada caso hace el Grid Search (~60 min);
# las otras 4 reutilizan los hiperparametros y solo entrenan el modelo final.
#
# uso:  nohup ./correr_experimentos.sh > corrida.log 2>&1 &
#
# Para seguir el progreso:  tail -f corrida.log
# Resultados:               /content/buckets/b1/exp/WF6212_resultados_grupoB.txt

DIR="$(cd "$(dirname "$0")" && pwd)"

EXP=6212
SEMILLAS="278911 278903 351217 525607 771937"
CASOS="E2 E3 C3 E4 E5 E6 E7 E2b"

for METODO in $CASOS; do
  for SEMILLA in $SEMILLAS; do
    if ! "$DIR/lanzador.sh" "$SEMILLA" "$METODO" "$EXP"; then
      echo "$(date '+%F %T')  FALLO  metodo=$METODO semilla=$SEMILLA  (sigo con la siguiente)"
    fi
  done
done

echo "$(date '+%F %T')  TERMINARON TODOS LOS CASOS"
