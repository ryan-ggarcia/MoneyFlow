document.addEventListener('DOMContentLoaded', function () {
    const backdrop = document.getElementById('mov-backdrop')
    const sheet = document.getElementById('mov-sheet')

    function abrir(dados) {
        const despesa = dados.tipo === 'DESPESA'

        document.getElementById('mov-edit-id').value = dados.id || ''
        document.getElementById('mov-edit-tipo').value = dados.tipo || 'RECEITA'
        document.getElementById('mov-edit-grupo').value = dados.grupo || ''
        document.getElementById('mov-edit-nome').value = dados.nome || ''
        document.getElementById('mov-edit-valor').value = dados.valor || ''
        document.getElementById('mov-edit-data').value = dados.data || ''
        document.getElementById('mov-edit-conta').value = dados.conta || '0'

        travarCampos(dados)

        const receitaSelect = document.getElementById('mov-categoria-receita')
        const despesaSelect = document.getElementById('mov-categoria-despesa')
        receitaSelect.classList.toggle('active', !despesa)
        receitaSelect.classList.toggle('desable', despesa)
        despesaSelect.classList.toggle('active', despesa)
        despesaSelect.classList.toggle('desable', !despesa)
        receitaSelect.value = despesa ? '0' : (dados.categoria || '0')
        despesaSelect.value = despesa ? (dados.categoria || '0') : '0'

        const valor = document.getElementById('mov-edit-valor')
        valor.classList.toggle('text-primary', !despesa)
        valor.classList.toggle('text-tertiary', despesa)

        document.getElementById('mov-sheet-titulo').textContent = despesa ? 'Editar despesa' : 'Editar receita'
        document.getElementById('mov-edit-icone').textContent = despesa ? 'shopping_cart' : 'payments'
        document.getElementById('mov-edit-nome').placeholder = despesa ? 'Ex: Mercado, Aluguel...' : 'Ex: Salário, Freelance...'

        backdrop.classList.add('is-open')
        sheet.classList.add('is-open')
        sheet.setAttribute('aria-hidden', 'false')
    }

    // Compra no cartão: só nome e categoria podem mudar
    function travarCampos(dados) {
        const noCartao = !!dados.grupo
        const aviso = document.getElementById('mov-aviso')

        aviso.classList.toggle('active', noCartao)
        aviso.classList.toggle('desable', !noCartao)
        document.getElementById('mov-aviso-texto').textContent = noCartao
            ? `Compra no cartão ${dados.cartao}${dados.parcela ? ` — parcela ${dados.parcela}` : ''}. O nome e a categoria valem para todas as parcelas; valor, data e conta não mudam por aqui.`
            : ''

        document.getElementById('mov-edit-valor').disabled = noCartao
        document.getElementById('mov-edit-data').disabled = noCartao
        document.getElementById('mov-edit-conta').disabled = noCartao
    }

    function fechar() {
        backdrop.classList.remove('is-open')
        sheet.classList.remove('is-open')
        sheet.setAttribute('aria-hidden', 'true')
    }

    document.querySelectorAll('.js-opcoes-movimentacao').forEach(function (botao) {
        botao.addEventListener('click', function (e) {
            e.stopPropagation()
            abrir(botao.dataset)
        })
    })

    document.getElementById('mov-fechar').addEventListener('click', fechar)
    backdrop.addEventListener('click', fechar)
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') fechar()
    })

    document.getElementById('btn-salvar-movimentacao').addEventListener('click', alterar)
    document.getElementById('btn-excluir-movimentacao').addEventListener('click', deletar)
})

function alterar() {
    let id = document.getElementById('mov-edit-id')
    let nome = document.getElementById('mov-edit-nome')
    let valor = document.getElementById('mov-edit-valor')
    let data = document.getElementById('mov-edit-data')
    let conta = document.getElementById('mov-edit-conta')
    let tipo = document.getElementById('mov-edit-tipo')
    let categoria = document.getElementById(tipo.value === 'DESPESA' ? 'mov-categoria-despesa' : 'mov-categoria-receita')

    const notfy = new Notyf()

    nome.style.borderColor = "green"
    valor.style.borderColor = "green"
    data.style.borderColor = "green"
    conta.style.borderColor = "green"
    categoria.style.borderColor = "green"

    const inputNome = nome.value.trim() === ""
    const inputValor = valor.value === ""
    const inputData = data.value === ""
    const inputConta = conta.value === "0"
    const inputCategoria = categoria.value === "0"

    if (inputNome && inputValor && inputData && inputConta && inputCategoria) {
        nome.style.borderColor = "red"
        valor.style.borderColor = "red"
        data.style.borderColor = "red"
        conta.style.borderColor = "red"
        categoria.style.borderColor = "red"
        notfy.error({
            message: "Preencha todos os campos!",
            icon: true,
            duration: 3000,
            position: { x: 'center', y: 'top' }
        })
    }
    if (inputNome || inputValor || inputData || inputConta || inputCategoria) {
        notfy.error({
            message: "Os campos destacados não foram preenchidos corretamente!",
            icon: true,
            duration: 5000,
            position: { x: 'center', y: 'top' }
        })
        if (inputNome) nome.style.borderColor = "red"
        if (inputValor) valor.style.borderColor = "red"
        if (inputData) data.style.borderColor = "red"
        if (inputConta) conta.style.borderColor = "red"
        if (inputCategoria) categoria.style.borderColor = "red"
    }

    if (!inputNome && !inputValor && !inputData && !inputConta && !inputCategoria) {
        fetch('/movimentacoes/alterar', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                id: id.value,
                tipo: tipo.value,
                nome: nome.value,
                valor: valor.value,
                data: data.value,
                conta: conta.value,
                categoria: categoria.value
            })
        })
            .then(r => r.json())
            .then(r => {
                if (r.ok) {
                    notfy.success({
                        message: "Sucesso! Movimentação alterada.",
                        icon: true,
                        duration: 3000,
                        position: { x: 'center', y: 'top' }
                    })
                    setTimeout(() => { window.location.reload() }, 3000)
                } else {
                    notfy.error({
                        message: r.msg,
                        icon: true,
                        duration: 5000,
                        position: { x: 'center', y: 'top' }
                    })
                }
            })
    }
}

function deletar() {
    let id = document.getElementById('mov-edit-id')
    const parcelada = !!document.getElementById('mov-edit-grupo').value
    Swal.fire({
        title: "Tem certeza?",
        text: parcelada
            ? "Essa movimentação é uma compra no cartão: todas as parcelas dela serão excluídas!"
            : "Você não conseguirá reverter isso!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Sim, deletar!"
    }).then((result) => {
        if (result.isConfirmed) {
            fetch('/movimentacoes/deletar', {
                method: 'POST',
                headers: { 'Content-type': 'application/json' },
                body: JSON.stringify({ id: id.value })
            })
                .then(r => r.json())
                .then(r => {
                    if (r.ok) {
                        Swal.fire({
                            title: `Receita excluida!`,
                            text: `A receita foi deletada com sucesso.`,
                            icon: "success"
                        });
                        setTimeout(() => {
                            window.location.reload()
                        }, 3000)
                    } else {
                        Swal.fire({
                            title: "Erro ao excluir receita...",
                            text: r.msg,
                            icon: "error"
                        })
                    }
                })
        }
    });
}
