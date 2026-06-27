# Gera o dashboard HTML completo com dados ICN embutidos
# Matheus Assis de Oliveira — UFMS

dir <- "C:/Users/Matheus/Documents/Claude Code Projects/R/icn"

mun_json <- readLines(file.path(dir, "docs/data_municipios.json"), encoding = "UTF-8")
set_json <- readLines(file.path(dir, "docs/data_setores.json"),    encoding = "UTF-8")
mat_json <- readLines(file.path(dir, "docs/data_matrix.json"),     encoding = "UTF-8")

mun_str <- paste(mun_json, collapse = "\n")
set_str <- paste(set_json, collapse = "\n")
mat_str <- paste(mat_json, collapse = "\n")

html <- paste0('<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ICN — Índice de Concentração Normalizado | MS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
<style>
:root{--cor:#1a6b3c;--cor2:#f39c12}
body{background:#f8f9fa;font-family:"Segoe UI",sans-serif}
.card-kpi{border:none;border-radius:12px;box-shadow:0 2px 8px rgba(0,0,0,.1);transition:.2s}
.card-kpi:hover{transform:translateY(-2px);box-shadow:0 4px 16px rgba(0,0,0,.15)}
.kpi-v{font-size:1.8rem;font-weight:700;color:var(--cor);line-height:1.1}
.kpi-l{font-size:.75rem;color:#6c757d;text-transform:uppercase;letter-spacing:.5px;margin-top:.25rem}
.nav-pills .nav-link.active{background:var(--cor)}
.nav-pills .nav-link{color:var(--cor)}
#map{height:520px;border-radius:10px}
.sec{border-left:4px solid var(--cor);padding-left:.75rem;margin-bottom:1.2rem;font-weight:600}
footer{background:#1a1a2e;color:#aaa;padding:1.5rem 0;font-size:.85rem}
</style>
</head>
<body>
<nav class="navbar py-2" style="background:var(--cor)">
  <div class="container">
    <span class="navbar-brand text-white fw-bold">ICN · Mato Grosso do Sul</span>
    <span class="text-white-50 small">Índice de Concentração Normalizado — Agropecuária (RAIS 2020)</span>
  </div>
</nav>

<div class="container my-4">
  <div class="row g-3 mb-4" id="kpis"></div>

  <ul class="nav nav-pills mb-3" id="tabs">
    <li class="nav-item"><a class="nav-link active" href="#" data-t="geral">Visão Geral</a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-t="mapa">Mapa</a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-t="mun">Municípios</a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-t="set">Setores</a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-t="tbl">Tabela</a></li>
  </ul>

  <div id="pg-geral">
    <div class="row g-4">
      <div class="col-md-7">
        <div class="card border-0 shadow-sm"><div class="card-body">
          <h6 class="sec">Top 20 Municípios por ICN Médio</h6>
          <div id="c-rank" style="height:480px"></div>
        </div></div>
      </div>
      <div class="col-md-5">
        <div class="card border-0 shadow-sm mb-3"><div class="card-body">
          <h6 class="sec">Distribuição do ICN Médio</h6>
          <div id="c-dist" style="height:210px"></div>
        </div></div>
        <div class="card border-0 shadow-sm"><div class="card-body">
          <h6 class="sec">Municípios Especializados por Setor</h6>
          <div id="c-nsp" style="height:215px"></div>
        </div></div>
      </div>
    </div>
  </div>

  <div id="pg-mapa" style="display:none">
    <div class="card border-0 shadow-sm"><div class="card-body">
      <h6 class="sec">ICN Médio — Mapa Coroplético (79 Municípios de MS)</h6>
      <div id="map"></div>
      <p class="text-muted small mt-2">Clique num município para ver detalhes. Verde escuro = alta especialização agrícola.</p>
    </div></div>
  </div>

  <div id="pg-mun" style="display:none">
    <div class="card border-0 shadow-sm"><div class="card-body">
      <h6 class="sec">Análise por Município</h6>
      <div class="row g-3 mb-3">
        <div class="col-md-5"><select id="sel-mun" class="form-select"></select></div>
      </div>
      <div class="row g-3">
        <div class="col-md-8"><div id="c-mun" style="height:520px"></div></div>
        <div class="col-md-4"><div id="inf-mun" class="p-3 bg-light rounded h-100"></div></div>
      </div>
    </div></div>
  </div>

  <div id="pg-set" style="display:none">
    <div class="card border-0 shadow-sm"><div class="card-body">
      <h6 class="sec">Análise por Setor</h6>
      <div class="row g-3 mb-3">
        <div class="col-md-7"><select id="sel-set" class="form-select"></select></div>
      </div>
      <div class="row g-3">
        <div class="col-md-8"><div id="c-set" style="height:480px"></div></div>
        <div class="col-md-4"><div id="inf-set" class="p-3 bg-light rounded"></div></div>
      </div>
    </div></div>
  </div>

  <div id="pg-tbl" style="display:none">
    <div class="card border-0 shadow-sm"><div class="card-body">
      <h6 class="sec">Tabela Completa — 79 Municípios</h6>
      <table id="dt" class="table table-sm table-hover w-100"></table>
    </div></div>
  </div>
</div>

<footer class="mt-5"><div class="container text-center">
  <strong class="text-white">Matheus Assis de Oliveira</strong> · Ciências Econômicas — UFMS<br>
  Dados: RAIS/MTE 2020 · Geometrias: geobr/IBGE · Método: ICN (QL + PR + IHH via ACP varimax)
</div></footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.plot.ly/plotly-2.27.0.min.js"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script>
const MUN = ', mun_str, ';
const SET = ', set_str, ';
const MAT = ', mat_str, ';

const C = "#1a6b3c", C2 = "#f39c12";
const fmt = v => v == null ? "—" : (+v).toFixed(4);
const s1  = s => Array.isArray(s) ? s[0] : s;

// KPIs
(function(){
  const avg = v => v.reduce((a,b)=>a+b,0)/v.length;
  const top = MUN.reduce((a,b) => a.icn_medio > b.icn_medio ? a : b);
  const items = [
    {v:"79",        l:"Municípios"},
    {v:"46",        l:"Subclasses CNAE"},
    {v:fmt(avg(MUN.map(m=>m.icn_medio))), l:"ICN Médio Geral"},
    {v:top.municipio, l:"Mais Especializado", s:"ICN "+fmt(top.icn_medio)},
    {v:MUN.filter(m=>m.n_especializados>0).length, l:"Municípios c/ Espec.≥1"},
  ];
  const cols=[2,2,2,3,3];
  document.getElementById("kpis").innerHTML = items.map((k,i)=>`
    <div class="col-md-${cols[i]}">
      <div class="card card-kpi p-3">
        <div class="kpi-v">${k.v}</div>
        <div class="kpi-l">${k.l}</div>
        ${k.s ? `<small class="text-muted">${k.s}</small>` : ""}
      </div></div>`).join("");
})();

// Ranking
(function(){
  const top = [...MUN].sort((a,b)=>b.icn_medio-a.icn_medio).slice(0,20);
  Plotly.newPlot("c-rank",[{
    type:"bar",orientation:"h",
    x:top.map(m=>m.icn_medio).reverse(),
    y:top.map(m=>m.municipio).reverse(),
    marker:{color:top.map(m=>m.icn_medio).reverse(),
            colorscale:[[0,"#c8e6c9"],[1,C]],showscale:false},
    text:top.map(m=>fmt(m.icn_medio)).reverse(),textposition:"outside",
    hovertemplate:"<b>%{y}</b><br>ICN: %{x:.4f}<extra></extra>"
  }],{margin:{l:180,r:70,t:5,b:40},
      xaxis:{title:"ICN Médio"},yaxis:{automargin:true},
      paper_bgcolor:"transparent",plot_bgcolor:"transparent"},{responsive:true});
})();

// Distribuição
(function(){
  Plotly.newPlot("c-dist",[{
    type:"histogram",x:MUN.map(m=>m.icn_medio),nbinsx:20,
    marker:{color:C,opacity:.8},
    hovertemplate:"ICN: %{x:.3f}<br>N: %{y}<extra></extra>"
  }],{margin:{l:45,r:10,t:5,b:35},
      xaxis:{title:"ICN Médio"},yaxis:{title:"N"},
      paper_bgcolor:"transparent",plot_bgcolor:"transparent"},{responsive:true});
})();

// N especializados por setor
(function(){
  const top = [...SET].sort((a,b)=>s1(b.n_espec)-s1(a.n_espec)).slice(0,12);
  Plotly.newPlot("c-nsp",[{
    type:"bar",orientation:"h",
    x:top.map(s=>s1(s.n_espec)).reverse(),
    y:top.map(s=>s1(s.setor).replace(/(.{28}).+/,"$1…")).reverse(),
    marker:{color:C2},
    hovertemplate:"<b>%{y}</b><br>Municípios: %{x}<extra></extra>"
  }],{margin:{l:205,r:30,t:5,b:35},
      xaxis:{title:"Municípios (ICN>1)"},yaxis:{automargin:true},
      paper_bgcolor:"transparent",plot_bgcolor:"transparent"},{responsive:true});
})();

// Mapa
let mapInit=false;
function doMap(){
  if(mapInit)return; mapInit=true;
  const map=L.map("map").setView([-20.5,-54.6],6);
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    {attribution:"© OpenStreetMap",maxZoom:10}).addTo(map);
  const byMun={}; MUN.forEach(m=>{byMun[m.municipio]=m;});
  function gc(v){
    if(v==null)return"#eee";
    if(v<0.05)return"#e8f5e9";
    if(v<0.15)return"#a5d6a7";
    if(v<0.30)return"#66bb6a";
    if(v<0.60)return"#2e7d32";
    if(v<1.0) return"#1b5e20";
    return"#0a2e10";
  }
  fetch("ms_municipios.geojson")
    .then(r=>r.json())
    .then(geo=>{
      L.geoJSON(geo,{
        style:f=>{
          const d=byMun[f.properties.name_muni]||{};
          return{fillColor:gc(d.icn_medio),weight:.7,color:"white",fillOpacity:.85};
        },
        onEachFeature:(f,layer)=>{
          const d=byMun[f.properties.name_muni]||{};
          layer.bindPopup(`<b>${f.properties.name_muni}</b><br>
            ICN Médio: <b>${fmt(d.icn_medio)}</b><br>
            Especializados: <b>${d.n_especializados??"—"}</b><br>
            Destaque: <i>${d.top_setor??"—"}</i>`);
          layer.on("mouseover",e=>e.target.setStyle({weight:2,color:C2}));
          layer.on("mouseout", e=>e.target.setStyle({weight:.7,color:"white"}));
        }
      }).addTo(map);
    })
    .catch(()=>{
      MUN.forEach(m=>{
        if(!m.lat||!m.lon)return;
        L.circleMarker([m.lat,m.lon],{
          radius:4+Math.min((m.icn_medio||0)*12,18),
          fillColor:gc(m.icn_medio),color:"white",weight:1,fillOpacity:.85
        }).bindPopup(`<b>${m.municipio}</b><br>ICN: ${fmt(m.icn_medio)}`).addTo(map);
      });
    });
}

// Municípios
(function(){
  const sel=document.getElementById("sel-mun");
  [...MUN].sort((a,b)=>a.municipio.localeCompare(b.municipio,"pt")).forEach(m=>{
    sel.innerHTML+=`<option>${m.municipio}</option>`;
  });
  function upd(nm){
    const row=MAT.find(r=>r.municipio===nm);
    const mun=MUN.find(m=>m.municipio===nm);
    if(!row)return;
    const pairs=SET.map(s=>{const n=s1(s.setor);return{n,v:row[n]||0};})
                   .sort((a,b)=>b.v-a.v);
    Plotly.newPlot("c-mun",[{
      type:"bar",orientation:"h",
      x:pairs.map(p=>p.v).reverse(),
      y:pairs.map(p=>p.n.replace(/(.{36}).+/,"$1…")).reverse(),
      marker:{color:pairs.map(p=>p.v>=1?C:"#90caf9").reverse()},
      text:pairs.map(p=>p.v.toFixed(3)).reverse(),textposition:"outside",
      hovertemplate:"<b>%{y}</b><br>ICN: %{x:.4f}<extra></extra>"
    }],{
      margin:{l:270,r:70,t:5,b:40},
      shapes:[{type:"line",x0:1,x1:1,y0:0,y1:1,yref:"paper",
               line:{color:"red",width:1.5,dash:"dash"}}],
      xaxis:{title:"ICN (vermelho = limiar 1)"},yaxis:{automargin:true},
      paper_bgcolor:"transparent",plot_bgcolor:"transparent"
    },{responsive:true});
    document.getElementById("inf-mun").innerHTML=`
      <h6 class="fw-bold">${nm}</h6><hr>
      <p class="mb-1"><small class="text-muted">ICN Médio</small><br>
        <strong class="fs-5">${fmt(mun?.icn_medio)}</strong></p>
      <p class="mb-1"><small class="text-muted">Especializados (ICN&gt;1)</small><br>
        <strong>${mun?.n_especializados??0}</strong></p>
      <p class="mb-1"><small class="text-muted">Setor Destaque</small><br>
        <strong style="font-size:.9rem">${mun?.top_setor??"—"}</strong></p>
      <p class="mb-0"><small class="text-muted">ICN Máximo</small><br>
        <strong>${fmt(mun?.top_icn)}</strong></p>
      <hr><small class="text-muted">Verde = especializado (ICN>1)<br>Azul = abaixo do limiar</small>`;
  }
  sel.addEventListener("change",()=>upd(sel.value));
  upd(sel.options[0]?.value);
})();

// Setores
(function(){
  const sel=document.getElementById("sel-set");
  SET.forEach((s,i)=>{sel.innerHTML+=`<option value="${i}">${s1(s.setor)}</option>`;});
  function upd(i){
    const s=SET[i], nm=s1(s.setor);
    const pairs=MAT.map(r=>({mun:r.municipio,v:r[nm]||0})).sort((a,b)=>b.v-a.v).slice(0,30);
    Plotly.newPlot("c-set",[{
      type:"bar",orientation:"h",
      x:pairs.map(p=>p.v).reverse(),
      y:pairs.map(p=>p.mun).reverse(),
      marker:{color:pairs.map(p=>p.v>=1?C:"#90caf9").reverse()},
      text:pairs.map(p=>p.v.toFixed(3)).reverse(),textposition:"outside",
      hovertemplate:"<b>%{y}</b><br>ICN: %{x:.4f}<extra></extra>"
    }],{
      margin:{l:180,r:70,t:5,b:40},
      shapes:[{type:"line",x0:1,x1:1,y0:0,y1:1,yref:"paper",
               line:{color:"red",width:1.5,dash:"dash"}}],
      xaxis:{title:"ICN"},yaxis:{automargin:true},
      paper_bgcolor:"transparent",plot_bgcolor:"transparent"
    },{responsive:true});
    document.getElementById("inf-set").innerHTML=`
      <h6 class="fw-bold">${nm}</h6><hr>
      <p class="mb-1"><small class="text-muted">Código CNAE</small><br>
        <strong>${s1(s.codigo)}</strong></p>
      <p class="mb-1"><small class="text-muted">ICN Médio (MS)</small><br>
        <strong>${fmt(s1(s.icn_medio))}</strong></p>
      <p class="mb-1"><small class="text-muted">ICN Máximo</small><br>
        <strong>${fmt(s1(s.icn_max))}</strong></p>
      <p class="mb-0"><small class="text-muted">Especializados</small><br>
        <strong>${s1(s.n_espec)} de 79</strong></p>
      <hr><small class="text-muted"><b>Top 5:</b><br>${(s.top5||[]).join("<br>")}</small>`;
  }
  sel.addEventListener("change",()=>upd(+sel.value));
  upd(0);
})();

// Tabela
let tblDone=false;
function doTbl(){
  if(tblDone)return; tblDone=true;
  document.getElementById("dt").innerHTML=
    `<thead><tr><th>Município</th><th>ICN Médio</th>
    <th>Espec. (ICN>1)</th><th>Setor Principal</th><th>ICN Máx.</th></tr></thead><tbody>`+
    [...MUN].sort((a,b)=>b.icn_medio-a.icn_medio).map(m=>
      `<tr><td>${m.municipio}</td><td>${fmt(m.icn_medio)}</td>
       <td>${m.n_especializados}</td><td>${m.top_setor||"—"}</td>
       <td>${fmt(m.top_icn)}</td></tr>`).join("")+"</tbody>";
  jQuery("#dt").DataTable({
    language:{search:"Buscar:",lengthMenu:"Mostrar _MENU_ municípios",
      info:"_START_–_END_ de _TOTAL_",
      paginate:{first:"Início",last:"Fim",previous:"Ant.",next:"Próx."},
      zeroRecords:"Nenhum resultado"},
    pageLength:20,order:[[1,"desc"]]});
}

// Navegação tabs
document.querySelectorAll("[data-t]").forEach(a=>{
  a.addEventListener("click",e=>{
    e.preventDefault();
    document.querySelectorAll("[data-t]").forEach(x=>x.classList.remove("active"));
    a.classList.add("active");
    const t=a.dataset.t;
    ["geral","mapa","mun","set","tbl"].forEach(id=>{
      document.getElementById("pg-"+id).style.display=id===t?"":"none";
    });
    if(t==="mapa") doMap();
    if(t==="tbl")  doTbl();
  });
});
</script>
</body>
</html>')

out_path <- file.path(dir, "docs/icn_dashboard.html")
writeLines(html, out_path, useBytes = FALSE)
cat("Dashboard criado:", out_path, "\n")
cat("Tamanho:", round(file.info(out_path)$size / 1024), "KB\n")
