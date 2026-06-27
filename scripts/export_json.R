# Exporta dados ICN como JSON para o dashboard HTML
library(readxl)
library(sf)
library(dplyr)
library(jsonlite)

icn_dir <- "C:/Users/Matheus/Documents/Claude Code Projects/R/icn"

# 1. Carregar dados ICN
icn_all <- read_excel(file.path(icn_dir, "output/ICN_all.xlsx"))
ql_all  <- read_excel(file.path(icn_dir, "output/QL.xlsx"))
pr_all  <- read_excel(file.path(icn_dir, "output/PR.xlsx"))
ihh_all <- read_excel(file.path(icn_dir, "output/IHH.xlsx"))

cat("ICN dims:", dim(icn_all), "\n")
cat("Colunas ICN:", colnames(icn_all)[1:5], "\n")

# 2. Carregar geometria
geo <- readRDS(file.path(icn_dir, "data/ms_municipios_sf.rds"))
cat("Geo dims:", dim(geo), "\n")
cat("Geo colunas:", colnames(geo), "\n")

# 3. Preparar tabela de municípios com ICN médio
# ICN_all: primeira coluna = municípios, demais = setores
mun_col <- colnames(icn_all)[1]
cat("Coluna município ICN:", mun_col, "\n")

icn_long <- icn_all
municipios_names <- icn_long[[1]]
icn_values <- icn_long[, -1]

# ICN médio por município
icn_medio <- rowMeans(icn_values, na.rm = TRUE)
icn_max   <- apply(icn_values, 1, max, na.rm = TRUE)
icn_min   <- apply(icn_values, 1, min, na.rm = TRUE)
n_setores_especializados <- rowSums(icn_values > 1, na.rm = TRUE)

df_mun <- data.frame(
  municipio = municipios_names,
  icn_medio = round(icn_medio, 4),
  icn_max   = round(icn_max, 4),
  icn_min   = round(icn_min, 4),
  n_especializados = n_setores_especializados,
  stringsAsFactors = FALSE
)

# 4. Pegar setores (nomes das colunas)
setores <- colnames(icn_values)
cat("N setores:", length(setores), "\n")
cat("Primeiros setores:", head(setores, 5), "\n")

# 5. Top setor por município
top_setor_idx <- apply(icn_values, 1, which.max)
df_mun$top_setor <- setores[top_setor_idx]
df_mun$top_icn   <- round(apply(icn_values, 1, max, na.rm = TRUE), 4)

# 6. Join com geometria (centroide)
cat("Classe geo:", class(geo), "\n")

# Verificar coluna de nome no sf
geo_names_col <- colnames(geo)
cat("Colunas geo:", geo_names_col, "\n")

# Calcular centroides
geo_centroid <- geo %>%
  mutate(
    lon = st_coordinates(st_centroid(geometry))[,1],
    lat = st_coordinates(st_centroid(geometry))[,2]
  ) %>%
  st_drop_geometry()

cat("Centroides calculados\n")

# Tentar fazer join - descobrir coluna de município no geo
# Geralmente name_muni ou nome_municipio
possible_name_cols <- c("name_muni", "nome_muni", "NM_MUN", "NM_MUNICIPIO", "municipio", "nome")
geo_name_col <- intersect(possible_name_cols, colnames(geo_centroid))
if (length(geo_name_col) == 0) {
  cat("Colunas disponíveis no geo:", colnames(geo_centroid), "\n")
  geo_name_col <- colnames(geo_centroid)[1]
}
cat("Coluna nome no geo:", geo_name_col[1], "\n")

# Normalizar nomes para join
normalize_name <- function(x) {
  x <- toupper(x)
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x <- gsub("[^A-Z ]", "", x)
  x <- trimws(gsub("\\s+", " ", x))
  x
}

geo_centroid$nome_clean <- normalize_name(geo_centroid[[geo_name_col[1]]])
df_mun$nome_clean       <- normalize_name(df_mun$municipio)

df_joined <- df_mun %>%
  left_join(geo_centroid %>% select(nome_clean, lon, lat), by = "nome_clean")

cat("Municípios com coordenadas:", sum(!is.na(df_joined$lon)), "/", nrow(df_joined), "\n")

# 7. Exportar JSON dos municípios
df_export <- df_joined %>% select(-nome_clean)
json_mun <- toJSON(df_export, pretty = TRUE, na = "null")
writeLines(json_mun, file.path(icn_dir, "docs/data_municipios.json"))
cat("Exportado: docs/data_municipios.json\n")

# 8. Exportar JSON dos setores com top municípios
setores_df <- lapply(seq_along(setores), function(i) {
  vals <- icn_values[[i]]
  ord  <- order(vals, decreasing = TRUE, na.last = TRUE)
  list(
    setor = setores[i],
    icn_medio = round(mean(vals, na.rm = TRUE), 4),
    icn_max   = round(max(vals, na.rm = TRUE), 4),
    n_especializados = sum(vals > 1, na.rm = TRUE),
    top5_municipios = municipios_names[ord[1:min(5, length(ord))]]
  )
})
json_set <- toJSON(setores_df, pretty = TRUE)
writeLines(json_set, file.path(icn_dir, "docs/data_setores.json"))
cat("Exportado: docs/data_setores.json\n")

# 9. Exportar matrix ICN completa (municípios x setores)
icn_matrix <- as.data.frame(icn_values)
icn_matrix$municipio <- municipios_names
icn_matrix <- icn_matrix[, c("municipio", setores)]
json_matrix <- toJSON(icn_matrix, pretty = FALSE, na = "null")
writeLines(json_matrix, file.path(icn_dir, "docs/data_matrix.json"))
cat("Exportado: docs/data_matrix.json\n")

# 10. Exportar GeoJSON para mapa coroplético
geo_icn <- geo %>%
  mutate(nome_clean = normalize_name(.data[[geo_name_col[1]]])) %>%
  left_join(df_mun %>% select(nome_clean, icn_medio, n_especializados, top_setor, top_icn),
            by = "nome_clean")

# Simplificar geometria para web
geo_simple <- st_simplify(geo_icn, dTolerance = 500, preserveTopology = TRUE)
st_write(geo_simple, file.path(icn_dir, "docs/ms_municipios.geojson"),
         delete_dsn = TRUE, quiet = TRUE)
cat("Exportado: docs/ms_municipios.geojson\n")

cat("\nConcluído! Estatísticas:\n")
cat("  Municípios:", nrow(df_mun), "\n")
cat("  Setores:", length(setores), "\n")
cat("  ICN médio geral:", round(mean(df_mun$icn_medio), 4), "\n")
cat("  Mun. mais especializado:", df_mun$municipio[which.max(df_mun$icn_medio)], "\n")
cat("  ICN máximo:", round(max(df_mun$icn_medio), 4), "\n")
