// Troca os botões de download pelo zip da versão mais recente. Sem rede ou
// com o limite da API do GitHub esgotado, os botões continuam levando à
// página da release, que também tem os arquivos.
const API = 'https://api.github.com/repos/jordaobass/anagram_app/releases/latest';

// O zip Intel também tem "macos" no nome: ele é conferido antes, senão o
// botão principal do Mac entregaria a versão Intel a quem tem Apple Silicon.
function sistemaDoArquivo(nome) {
  if (/windows/i.test(nome)) return 'windows';
  if (/macos-intel/i.test(nome)) return 'macos-intel';
  if (/macos/i.test(nome)) return 'macos';
  return null;
}

function apontarDownloads(assets) {
  for (const asset of assets) {
    const sistema = sistemaDoArquivo(asset.name);
    if (!sistema) continue;
    document.querySelectorAll(`[data-baixar="${sistema}"]`).forEach((link) => {
      link.href = asset.browser_download_url;
    });
  }
}

function mostrarVersao(versao) {
  document.querySelectorAll('[data-versao]').forEach((el) => { el.textContent = `Version ${versao}`; });
  document.querySelectorAll('[data-versao-barra]').forEach((el) => { el.textContent = `v${versao} is out`; });
}

try {
  const resposta = await fetch(API, { headers: { Accept: 'application/vnd.github+json' } });
  if (resposta.ok) {
    const release = await resposta.json();
    apontarDownloads(release.assets || []);
    const versao = String(release.tag_name || '').replace(/^v/, '');
    if (versao) mostrarVersao(versao);
  }
} catch (error) {
  console.warn('Anagram App: não consegui ler a versão mais recente', API, error);
}
