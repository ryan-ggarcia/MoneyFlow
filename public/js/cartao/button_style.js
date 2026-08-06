document.addEventListener("DOMContentLoaded", function () {
  const cartoes = document.querySelectorAll('.credit-card');

  if (cartoes.length === 0) return;

  function selecionarCartao(escolhido) {
    cartoes.forEach(cartao => {
      const selecionado = cartao === escolhido;
      cartao.classList.toggle('credit-card-selecionado', selecionado);
      cartao.setAttribute('aria-pressed', selecionado);
    });
    escolhido.scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });
  }

  cartoes.forEach(cartao => {
    cartao.addEventListener('click', function (e) {
        if (cartao.classList.contains('credit-card-selecionado')) {
          e.stopImmediatePropagation();
          return;
        }
        selecionarCartao(cartao);
    });
    cartao.addEventListener('keydown', function (e) {
      if (e.key !== 'Enter' && e.key !== ' ') return;
      e.preventDefault();
      selecionarCartao(cartao);
    });
    cartao.addEventListener('blur', function (e) {
      if (e.relatedTarget && e.relatedTarget.closest('.credit-card')) return;
      window.location.reload();
    });
  });
});
