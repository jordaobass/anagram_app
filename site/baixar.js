// Troca os botões de download pelo zip da versão mais recente. Sem rede ou
// com o limite da API do GitHub esgotado, os botões continuam levando à
// página da release, que também tem os arquivos.
(async function () {
  const API = 'https://api.github.com/repos/jordaobass/anagram_app/releases/latest';
  try {
    const resposta = await fetch(API, { headers: { Accept: 'application/vnd.github+json' } });
    if (!resposta.ok) return;
    const release = await resposta.json();
    const versao = String(release.tag_name || '').replace(/^v/, '');
    for (const asset of release.assets || []) {
      const sistema = /windows/i.test(asset.name) ? 'windows' : /macos/i.test(asset.name) ? 'macos' : null;
      if (!sistema) continue;
      document.querySelectorAll(`[data-baixar="${sistema}"]`).forEach((link) => {
        link.href = asset.browser_download_url;
      });
    }
    if (!versao) return;
    document.querySelectorAll('[data-versao]').forEach((el) => { el.textContent = `Version ${versao}`; });
    document.querySelectorAll('[data-versao-barra]').forEach((el) => { el.textContent = `v${versao} is out`; });
  } catch (erro) {
    console.warn('Anagram App: não consegui ler a versão mais recente', API, erro);
  }
})();
