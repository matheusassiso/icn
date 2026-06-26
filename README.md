# ICN — Indicadores de Análise Regional por UF

[![Render & Publish](https://github.com/matheusassiso/icn/actions/workflows/render.yml/badge.svg)](https://github.com/matheusassiso/icn/actions/workflows/render.yml)
[![GitHub Pages](https://img.shields.io/badge/Relatório%20Completo-GitHub%20Pages-blue?logo=github)](https://matheusassiso.github.io/icn/)

Repositório desenvolvido para a disciplina de **Economia Regional e Urbana** (graduação em Economia), com base em:

> MONASTERIO, L. Indicadores de análise regional e espacial. In: CRUZ, B. O. *et al.* (orgs.). **Economia Regional e Urbana: Teorias e métodos com ênfase no Brasil**. Brasília: Ipea, 2011. Cap. 10, p. 315–331.

Os dados são os **vínculos formais de emprego por subclasse CNAE** dos 27 estados brasileiros (RAIS 2020, PDET/MTE). As figuras abaixo são geradas automaticamente pelo GitHub Actions a cada push.

---

## Indicadores calculados

| Indicador | Sigla | Fórmula | Objetivo | Limites teóricos |
|-----------|-------|---------|----------|-----------------|
| Quociente Locacional | QL | $\frac{E_{ki}/E_i}{E_k/E}$ | Especialização regional por setor | $[0, +\infty)$ |
| Participação Relativa | PR | $\frac{E_{ki}}{E_k}$ | Peso do estado no setor nacional | $[0, 1]$ |
| Hirschman-Herfindahl modificado | IHH | $\frac{E_{ki}}{E_k} - \frac{E_i}{E}$ | Concentração espacial do setor | $[-1, 1]$ |
| Concentração Normalizada | ICN | ACP(QL, IHH, PR) | Índice síntese via componentes principais | $(-\infty, +\infty)$ |

Todas as fórmulas seguem o **Quadro Síntese** da p. 330 do livro.

---

## Estrutura do repositório

```
icn/
├── R/
│   └── code.R                       # Funções QL(), PR(), IHH(), ICN()
├── data/
│   └── dados.rds                    # Dados RAIS 2020 (27 UFs × subclasses CNAE)
├── figures/                         # Gerado automaticamente — não editar
├── .github/workflows/render.yml     # CI/CD: renderiza o Rmd e publica no Pages
├── ql_estados_brasil.Rmd            # Análise principal — knit para gerar o relatório
├── .gitignore
└── teer real.Rproj
```

---

## Mapas e visualizações

> As figuras são geradas pelo GitHub Actions ao renderizar `ql_estados_brasil.Rmd`.
> Se aparecerem quebradas, aguarde o workflow terminar ou rode o Rmd localmente.

### Emprego formal por grande região e estado

![Emprego por região](figures/01_emprego_regioes.png)

---

### Mapa: emprego formal total por estado

![Mapa emprego total](figures/02_mapa_emprego.png)

---

### Mapa: QL médio por estado

> **QL > 1** — região relativamente especializada no setor comparado ao perfil nacional.

![Mapa QL médio](figures/03_mapa_ql_medio.png)

---

### Mapa: número de setores com QL > 1

![Mapa nº setores especializados](figures/04_mapa_n_setores.png)

---

### QL médio por estado e grande região

![QL por região](figures/05_ql_por_regiao.png)

---

### Painel: top 5 setores por estado (QL)

![Painel top 5 por estado](figures/06_painel_top5_setores.png)

---

### Dispersão: QL médio × diversificação por estado

![Scatter QL médio vs diversificação](figures/07_scatter_ql_diversificacao.png)

---

### Mapa: |IHH| médio por estado

![Mapa IHH médio](figures/08_mapa_ihh.png)

---

### Top 15 subclasses com maior concentração espacial (IHH)

![IHH top 15 setores](figures/09_ihh_top15.png)

---

### Heatmap: Participação Relativa (PR) — 20 maiores subclasses × estados

![Heatmap PR](figures/10_heatmap_pr.png)

---

### Mapa: ICN médio por estado

> O ICN combina QL, PR e IHH via ACP com rotação Varimax. Pesos = proporção da variância explicada por cada componente.

![Mapa ICN médio](figures/11_mapa_icn_medio.png)

---

### Mapa: ICN máximo por estado (setor mais concentrado)

![Mapa ICN máximo](figures/12_mapa_icn_max.png)

---

### Ranking dos estados por ICN médio

![Ranking ICN](figures/13_ranking_icn.png)

---

### Correlação ICN × QL por estado

![Scatter ICN vs QL](figures/14_scatter_icn_ql.png)

---

### Distribuição dos indicadores por grande região

![Boxplots por região](figures/15_boxplot_regioes.png)

---

## Como reproduzir localmente

```r
# 1. Instalar pacotes (apenas na primeira vez)
install.packages(c(
  "tidyverse", "readxl", "writexl", "psych",
  "geobr", "sf", "viridis", "scales", "patchwork",
  "ggrepel", "knitr", "kableExtra", "RColorBrewer"
))

# 2. Renderizar (com o projeto aberto no RStudio)
rmarkdown::render("ql_estados_brasil.Rmd")
```

O Rmd gera automaticamente as figuras em `figures/` e os resultados em `output/`.

---

## Referências

MONASTERIO, L. Indicadores de análise regional e espacial. In: CRUZ, B. O. *et al.* (orgs.). **Economia Regional e Urbana: Teorias e métodos com ênfase no Brasil**. Brasília: Ipea, 2011. Cap. 10, p. 315–331.

PEREIRA, R. H. M. *et al.* **geobr**: Loads Shapefiles of Official Spatial Data Sets of Brazil. R package. Disponível em: <https://github.com/ipeaGIT/geobr>.

RAIS. **Relação Anual de Informações Sociais** — 2020. Ministério do Trabalho e Emprego. Disponível em: <http://pdet.mte.gov.br/>.
