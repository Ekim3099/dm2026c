# Semillerio para Kaggle
# Promedia las probabilidades de las corridas en modo kaggle (future 202109)
# del caso ganador y genera un CSV por cada corte de envios.
#
# Antes de correrlo:
#   for s in 278911 278903 351217 525607 771937; do ./lanzador.sh $s <CASO_GANADOR> 6212 TRUE; done
#
# uso:  Rscript semillerio_kaggle.R <caso_ganador> [exp]

require("data.table")

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("uso: Rscript semillerio_kaggle.R <caso_ganador> [exp]")

caso <- args[1]
exp <- ifelse(length(args) >= 2, args[2], "6212")
cortes <- seq(9000, 13000, by = 500)

base <- "/content/buckets/b1/exp"
carpetas <- Sys.glob(file.path(base, paste0("WF", exp, "_", caso, "_s*_kaggle")))
if (length(carpetas) == 0) stop("no encontre corridas en modo kaggle para el caso ", caso)

cat("Semillas encontradas:", length(carpetas), "\n")
print(basename(carpetas))

preds <- rbindlist(lapply(carpetas, function(carpeta) {
  fread(file.path(carpeta, "prediccion.txt"))[, list(numero_de_cliente, prob)]
}))

tb <- preds[, list(prob = mean(prob), n_semillas = .N), by = numero_de_cliente]
setorder(tb, -prob)

salida <- file.path(base, paste0("WF", exp, "_semillerio_", caso))
dir.create(salida, showWarnings = FALSE)

for (envios in cortes) {
  tb[, Predicted := 0L]
  tb[1:envios, Predicted := 1L]
  fwrite(tb[, list(numero_de_cliente, Predicted)],
    file = file.path(salida, paste0("KA", exp, "_semillerio_", caso, "_", envios, ".csv")),
    sep = ",")
}

fwrite(tb[, list(numero_de_cliente, prob, n_semillas)],
  file = file.path(salida, "prob_promedio.txt"), sep = "\t")

cat("CSV generados en", salida, "\n")
