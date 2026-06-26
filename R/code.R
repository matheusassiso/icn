# Indicadores de análise regional e espacial
# Referência: Monasterio (2011), Cap. 10 em Cruz et al. (orgs.)
#   "Economia Regional e Urbana: Teorias e métodos com ênfase no Brasil". Ipea.
#
# Dados esperados: matriz (regiões x setores) com emprego (ou outro fluxo).
# Convenção: linhas = regiões (estados), colunas = setores (subclasses CNAE).

# QL — Quociente Locacional ---------------------------------------------------
# QL_ki = (E_ki / E_i) / (E_k / E)
# Valor > 1: região relativamente especializada no setor k.
QL <- function(mat) {
  mat <- as.matrix(mat)
  share_regiao   <- mat / rowSums(mat)
  share_nacional <- colSums(mat) / sum(mat)
  ql <- t(t(share_regiao) / share_nacional)
  ql[is.na(ql)] <- 0
  ql
}

# PR — Participação Relativa --------------------------------------------------
# PR_ki = E_ki / E_k  (participação de cada região no total nacional do setor)
PR <- function(mat) {
  mat <- as.matrix(mat)
  pr  <- t(t(mat) / colSums(mat))
  pr[is.na(pr)] <- 0
  pr
}

# IHH — Índice Hirschman-Herfindahl modificado --------------------------------
# IHH_ki = (E_ki / E_k) - (E_i / E)  = PR_ki - s_i
# Mede concentração setorial; varia em [-1, 1].
IHH <- function(mat) {
  mat <- as.matrix(mat)
  pr  <- PR(mat)
  s_i <- rowSums(mat) / sum(mat)
  ihh <- pr - matrix(s_i, nrow = nrow(mat), ncol = ncol(mat))
  ihh[is.na(ihh)] <- 0
  ihh
}

# ICN — Índice de Concentração Normalizada ------------------------------------
# Combina QL, IHH e PR via ACP com rotação varimax.
# O peso de cada componente é a proporção da variância explicada pelo fator.
#
# Args:
#   nomes : vetor de nomes das regiões (deve ter comprimento = nrow(ql))
#   ql    : matriz retornada por QL()
#   ihh   : matriz retornada por IHH()
#   pr    : matriz retornada por PR()
#
# Retorna data.frame com colunas: regiao + uma coluna numérica por setor.
ICN <- function(nomes, ql, ihh, pr) {
  stopifnot(
    ncol(ql) == ncol(ihh), ncol(ql) == ncol(pr),
    nrow(ql) == nrow(ihh), nrow(ql) == nrow(pr),
    length(nomes) == nrow(ql)
  )

  resultado <- data.frame(regiao = nomes)

  for (k in seq_len(ncol(ql))) {
    componentes <- data.frame(QL = ql[, k], IHH = ihh[, k], PR = pr[, k])

    x   <- scale(componentes)
    pca <- psych::principal(x, rotate = "varimax", nfactors = 3,
                            scores = FALSE, oblique.scores = TRUE)

    loadings      <- as.data.frame(unclass(pca$loadings))
    matriz_normal <- t(t(loadings) / rowSums(t(loadings)))
    prop_var      <- t(as.data.frame(unclass(pca$Vaccounted))[2, ])

    theta <- matriz_normal %*% prop_var
    icn_k <- as.matrix(componentes) %*% matrix(theta, nrow = 3, ncol = 1)

    resultado <- cbind(resultado, round(icn_k, digits = 3))
  }

  colnames(resultado) <- c("regiao", seq_len(ncol(ql)))
  resultado
}
