# Analisis de los casos del Grupo B
# Genera:
#   - tabla_resultados.txt : ganancia promedio, desvio, envios y AUC por caso (para la slide de Resultados)
#   - curvas_por_caso.pdf  : una pagina por caso, 5 semillas en gris + promedio en rojo (para la slide de Curvas)
#
# uso:  Rscript analisis_resultados.R [exp]

require("data.table")

args <- commandArgs(trailingOnly = TRUE)
exp <- ifelse(length(args) >= 1, args[1], "6212")
base <- "/content/buckets/b1/exp"
salida <- file.path(base, paste0("WF", exp, "_analisis"))
dir.create(salida, showWarnings = FALSE)

# ---------------- tabla de resultados ----------------
res <- fread(file.path(base, paste0("WF", exp, "_resultados_grupoB.txt")))

# si una semilla se corrio dos veces, me quedo con la ultima
res <- unique(res, by = c("caso", "semilla"), fromLast = TRUE)

tabla <- res[, list(
  ganancia_prom = round(mean(ganancia_suavizada_max)),
  desvio = round(sd(ganancia_suavizada_max)),
  envios_prom = round(mean(envios)),
  AUC_validacion = round(mean(AUC_validacion), 5),
  meses_training = meses_training[1],
  semillas = .N
), by = caso]
setorder(tabla, -ganancia_prom)

fwrite(tabla, file.path(salida, "tabla_resultados.txt"), sep = "\t")
print(tabla)

# ---------------- curvas por caso ----------------
rango <- 8000:20000

pdf(file.path(salida, "curvas_por_caso.pdf"))
for (caso in tabla$caso) {
  archivos <- Sys.glob(file.path(base, paste0("WF", exp, "_", caso, "_s*"), "ganancias.txt"))
  if (length(archivos) == 0) next

  m <- sapply(archivos, function(a) fread(a, select = "gan_acum")[rango, gan_acum])
  prom <- rowMeans(m)

  matplot(rango, m, type = "l", lty = 1, col = "gray",
    xlab = "Envios", ylab = "Ganancia",
    main = paste0("caso ", caso, "   mejor gan prom = ", as.integer(max(prom)),
      "   envios = ", rango[which.max(prom)]))
  lines(rango, prom, col = "red", lwd = 2)
  grid()
}
dev.off()

cat("Listo:", salida, "\n")
