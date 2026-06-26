# ICN — Indicadores de Análise Regional por UF

[![Render & Publish](https://github.com/matheusassiso/icn/actions/workflows/render.yml/badge.svg)](https://github.com/matheusassiso/icn/actions/workflows/render.yml)
[![GitHub Pages](https://img.shields.io/badge/Relatório%20Completo-GitHub%20Pages-blue?logo=github)](https://matheusassiso.github.io/icn/)

Repositório desenvolvido para a disciplina de **Economia Regional e Urbana**
(graduação em Economia), com base metodológica em:

> MONASTERIO, L. Indicadores de análise regional e espacial. In: CRUZ, B. O.
> *et al.* (orgs.). **Economia Regional e Urbana: Teorias e métodos com ênfase
> no Brasil**. Brasília: Ipea, 2011. Cap. 10, p. 315–331.

Os dados são os **vínculos formais de emprego por subclasse CNAE** dos 27
estados brasileiros (RAIS 2020, PDET/MTE). O relatório interativo completo
(HTML) é publicado automaticamente no **[GitHub Pages](https://matheusassiso.github.io/icn/)**.

---

## Indicadores calculados

| Indicador | Sigla | Fórmula | Objetivo | Limites |
|-----------|-------|---------|----------|---------|
| Quociente Locacional | QL | $(E_{ki}/E_i)\,/\,(E_k/E)$ | Especialização regional | $[0,\infty)$ |
| Participação Relativa | PR | $E_{ki}/E_k$ | Peso do estado no setor | $[0,1]$ |
| Hirschman-Herfindahl modificado | IHH | $PR_{ki} - s_i$ | Concentração espacial | $[-1,1]$ |
| Concentração Normalizada | ICN | ACP(QL, IHH, PR) | Índice síntese | $(-\infty,\infty)$ |

---

## Resultados e mapas

### Emprego formal por grande região e estado

![Emprego por região](figures/01_emprego_regioes.png)

O Sudeste concentra a maior parcela do emprego formal. São Paulo, Minas Gerais,
Rio de Janeiro e Paraná se destacam no ranking estadual.

---

### Mapa: emprego formal total por estado

![Mapa emprego total](figures/02_mapa_emprego.png)

---

## Quociente Locacional (QL)

> **QL > 1** → região relativamente especializada no setor comparado com o
> perfil nacional.

### Mapa: QL médio por estado

![Mapa QL médio](figures/03_mapa_ql_medio.png)

Estados menores com estrutura produtiva concentrada tendem a apresentar QL
médio mais elevado — sinal de alta especialização em poucos setores.

### Mapa: número de setores com QL > 1

![Mapa nº setores](figures/04_mapa_n_setores.png)

Mede a *diversificação* da especialização. Estados do Sudeste especializam-se
em mais setores simultaneamente, enquanto estados da Amazônia concentram seus
QLs altos em poucos ramos.

### QL médio por grande região

![QL por região](figures/05_ql_por_regiao.png)

---

## Investigação por estado

### Painel: top 5 setores com maior QL por estado

![Painel top 5](figures/06_painel_top5_setores.png)

Cada mini-gráfico mostra o perfil de especialização produtiva de um estado.
Permite identificar de imediato quais subclasses CNAE distinguem cada UF.

### Dispersão: QL médio × diversificação

![Scatter QL](figures/07_scatter_ql_diversificacao.png)

Há uma relação positiva entre a intensidade média de especialização (QL médio)
e o número de setores especializados (QL > 1). Economias maiores tendem a se
especializar em mais setores *e* com maior intensidade.

---

## Índice Hirschman-Herfindahl (IHH)

> Mede o desvio da participação de cada estado em um setor em relação ao
> seu peso no emprego total. Valores positivos indicam sobrerrepresentação.

### Mapa: |IHH| médio por estado

![Mapa IHH](figures/08_mapa_ihh.png)

### Top 15 subclasses com maior concentração espacial

![IHH top 15](figures/09_ihh_top15.png)

Setores ligados à extração de recursos naturais, agronegócio regional e
serviços intensivos figuram entre os mais geograficamente concentrados.

---

## Participação Relativa (PR)

### Heatmap: PR das 20 maiores subclasses × estado

![Heatmap PR](figures/10_heatmap_pr.png)

Cor mais escura = maior participação do estado no total nacional daquele setor.
São Paulo domina a maioria dos grandes setores; estados especializados aparecem
como manchas escuras em colunas específicas.

---

## ICN — Índice de Concentração Normalizada

> Combina QL, PR e IHH via **Análise de Componentes Principais** (rotação
> Varimax). Cada componente é ponderado pela proporção da variância que
> explica. Metodologia: Monasterio (2011), Cap. 10.

### Mapa: ICN médio por estado

![Mapa ICN médio](figures/11_mapa_icn_medio.png)

### Mapa: ICN máximo por estado (setor mais concentrado)

![Mapa ICN máximo](figures/12_mapa_icn_max.png)

### Ranking dos estados por ICN médio

![Ranking ICN](figures/13_ranking_icn.png)

Estados com menor porte econômico relativo tendem a ICN médio mais alto —
suas estruturas produtivas são mais concentradas em poucos setores de alta
especialização.

---

## Análise comparativa

### Correlação ICN × QL por estado

![Scatter ICN × QL](figures/14_scatter_icn_ql.png)

### Distribuição dos indicadores por grande região

![Boxplots por região](figures/15_boxplot_regioes.png)

As regiões Norte e Nordeste apresentam maior variabilidade interna nos
indicadores, refletindo heterogeneidade econômica entre seus estados. O
Sudeste tem distribuição mais compacta, típica de economias mais integradas.

---

## Estrutura do repositório

```
icn/
├── code.R                        # Funções QL(), PR(), IHH(), ICN()
├── ql_estados_brasil.Rmd         # Análise completa — knit para o relatório
├── figures/                      # PNGs gerados automaticamente pelo Rmd
├── dados.rds                     # Dados RAIS 2020 em formato R
├── QL.xlsx / PR.xlsx             # Matrizes de indicadores (estados × setores)
├── IHH.xlsx / ICN_all.xlsx       # Exportações em Excel
├── teer real.Rproj               # Projeto RStudio
└── .github/workflows/render.yml  # CI/CD: renderiza, salva figuras e publica
```

---

## Como reproduzir

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

Isso gera o HTML e salva todos os PNGs em `figures/`.

---

## Referências

MONASTERIO, L. Indicadores de análise regional e espacial. In: CRUZ, B. O.
*et al.* (orgs.). **Economia Regional e Urbana: Teorias e métodos com ênfase
no Brasil**. Brasília: Ipea, 2011. Cap. 10, p. 315–331.

PEREIRA, R. H. M. *et al.* **geobr**: Loads Shapefiles of Official Spatial
Data Sets of Brazil. R package. <https://github.com/ipeaGIT/geobr>.

RAIS. **Relação Anual de Informações Sociais** — 2020. Ministério do Trabalho
e Emprego. <http://pdet.mte.gov.br/>.
