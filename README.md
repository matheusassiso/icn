# ICN — Indicadores de Análise Regional · Municípios do MS

[![Render & Publish](https://github.com/matheusassiso/icn/actions/workflows/render.yml/badge.svg)](https://github.com/matheusassiso/icn/actions/workflows/render.yml)
[![Relatório](https://img.shields.io/badge/Relatório-GitHub%20Pages-blue?logo=github)](https://matheusassiso.github.io/icn/)

Repositório desenvolvido para a disciplina de **Economia Regional e Urbana** (graduação em Economia), com base em:

> MONASTERIO, L. Indicadores de análise regional e espacial. In: CRUZ, B. O. *et al.* (orgs.). **Economia Regional e Urbana: Teorias e métodos com ênfase no Brasil**. Brasília: Ipea, 2011. Cap. 10, p. 315–331.

Os dados são vínculos de **emprego formal agropecuário** (subclasses CNAE) nos **79 municípios do Mato Grosso do Sul** — RAIS/MTE.

---

## Indicadores

| Sigla | Nome | Fórmula | O que mede | Limites |
|-------|------|---------|------------|---------|
| **QL** | Quociente Locacional | $(E_{ki}/E_i)\,/\,(E_k/E)$ | Especialização do município no setor | $[0,\infty)$ |
| **PR** | Participação Relativa | $E_{ki}/E_k$ | Peso do município no setor estadual | $[0,1]$ |
| **IHH** | Hirschman-Herfindahl mod. | $PR_{ki} - s_i$ | Concentração espacial do setor | $[-1,1]$ |
| **ICN** | Concentração Normalizada | ACP(QL, IHH, PR) | Índice síntese via componentes principais | $(-\infty,\infty)$ |

---

## Estrutura

```
icn/
├── R/code.R                      → funções QL(), PR(), IHH(), ICN()
├── data/
│   ├── dados.rds                 → emprego formal agropecuário (79 mun × 46 subclasses)
│   └── ms_municipios_sf.rds      → geometria dos municípios de MS (geobr/IBGE 2020)
├── figures/                      → PNGs gerados pelo Rmd
├── ql_estados_brasil.Rmd         → análise completa
├── .github/workflows/render.yml  → CI/CD → GitHub Pages
└── teer real.Rproj
```

---

## Resultados

### Top 15 municípios por emprego agropecuário

![Top 15 emprego](figures/01_top15_emprego.png)

---

### Mapa: emprego agropecuário total

![Mapa emprego](figures/02_mapa_emprego.png)

---

### Mapa: QL médio por município

> **QL > 1** — município especializado no setor em relação à média estadual.

![Mapa QL médio](figures/03_mapa_ql_medio.png)

---

### Mapa: número de subclasses com QL > 1

![Mapa nº setores](figures/04_mapa_n_setores.png)

---

### Ranking: QL médio — top 20 municípios

![Ranking QL](figures/05_ranking_ql.png)

---

### Dispersão: QL médio × diversificação

![Scatter QL](figures/06_scatter_ql.png)

---

### Mapa: |IHH| médio por município

![Mapa IHH](figures/07_mapa_ihh.png)

---

### Top 15 subclasses com maior concentração espacial (IHH)

![IHH top 15](figures/08_ihh_top15.png)

---

### Heatmap: Participação Relativa (PR)

![Heatmap PR](figures/09_heatmap_pr.png)

---

### Mapa: ICN médio por município

> ICN combina QL, PR e IHH via ACP com rotação Varimax (Monasterio, 2011, Cap. 10).

![Mapa ICN médio](figures/10_mapa_icn_medio.png)

---

### Mapa: ICN — paleta Spectral

![Mapa ICN spectral](figures/11_mapa_icn_spectral.png)

---

### Ranking: top 20 municípios por ICN médio

![Ranking ICN](figures/12_ranking_icn.png)

---

### Correlação ICN × QL

![Scatter ICN vs QL](figures/13_scatter_icn_ql.png)

---

### Painel: top 5 subclasses por QL — 12 maiores municípios

![Painel top 5](figures/14_painel_top5.png)

---

## Como reproduzir

```r
# Instalar pacotes (apenas na primeira vez)
install.packages(c(
  "tidyverse", "readxl", "writexl", "psych", "sf",
  "viridis", "scales", "patchwork", "ggrepel",
  "knitr", "kableExtra", "RColorBrewer"
))

# Renderizar (com o projeto aberto no RStudio)
rmarkdown::render("ql_estados_brasil.Rmd")
```

---

## Referências

MONASTERIO, L. Indicadores de análise regional e espacial. In: CRUZ, B. O. *et al.* (orgs.). **Economia Regional e Urbana: Teorias e métodos com ênfase no Brasil**. Brasília: Ipea, 2011. Cap. 10.

PEREIRA, R. H. M. *et al.* **geobr**: Loads Shapefiles of Official Spatial Data Sets of Brazil. <https://github.com/ipeaGIT/geobr>.

RAIS — Relação Anual de Informações Sociais, 2020. MTE. <http://pdet.mte.gov.br/>.
