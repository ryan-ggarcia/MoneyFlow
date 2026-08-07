document.addEventListener('DOMContentLoaded', function () {
    const backdrop = document.getElementById('car-backdrop')
    const sheet = document.getElementById('car-sheet')

    function abrir(dados) {
        document.getElementById('car-edit-id').value = dados.id || ''
        document.getElementById('car-edit-nome').value = dados.nome || ''
        document.getElementById('car-edit-tipo').value = dados.tipo || 'DEBITO'
        document.getElementById('car-edit-status').value = dados.status || 'ATIVO'
        document.getElementById('car-edit-conta').value = dados.conta || '0'
        document.getElementById('car-edit-limite').value = dados.limite || ''
        document.getElementById('car-edit-fechamento').value = dados.fechamento || ''
        document.getElementById('car-edit-vencimento').value = dados.vencimento || ''

        mostrarCredito()

        backdrop.classList.add('is-open')
        sheet.classList.add('is-open')
        sheet.setAttribute('aria-hidden', 'false')
    }

    // Limite, fechamento e vencimento só existem no crédito
    function mostrarCredito() {
        const credito = document.getElementById('car-edit-tipo').value === 'CREDITO'
        const bloco = document.getElementById('car-edit-credito')
        bloco.classList.toggle('active', credito)
        bloco.classList.toggle('desable', !credito)
    }

    function fechar() {
        backdrop.classList.remove('is-open')
        sheet.classList.remove('is-open')
        sheet.setAttribute('aria-hidden', 'true')
    }

    document.querySelectorAll('.js-opcoes-cartao').forEach(function (botao) {
        botao.addEventListener('click', function (e) {
            e.stopPropagation()
            abrir(botao.dataset)
        })
    })

    document.getElementById('car-edit-tipo').addEventListener('change', mostrarCredito)
    document.getElementById('car-fechar').addEventListener('click', fechar)
    backdrop.addEventListener('click', fechar)
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') fechar()
    })

    document.getElementById('btn-salvar-cartao').addEventListener('click', alterarCartao)
    document.getElementById('btn-excluir-cartao').addEventListener('click', deletarCartao)
})

function alterarCartao() {
    let id = document.getElementById('car-edit-id')
    let nome = document.getElementById('car-edit-nome')
    let tipo = document.getElementById('car-edit-tipo')
    let status = document.getElementById('car-edit-status')
    let conta = document.getElementById('car-edit-conta')
    let limite = document.getElementById('car-edit-limite')
    let fechamento = document.getElementById('car-edit-fechamento')
    let vencimento = document.getElementById('car-edit-vencimento')

    const notfy = new Notyf()
    const credito = tipo.value === 'CREDITO'

    nome.style.borderColor = "green"
    conta.style.borderColor = "green"
    fechamento.style.borderColor = "green"
    vencimento.style.borderColor = "green"

    const inputNome = nome.value.trim() === ""
    const inputConta = conta.value === "0"
    const inputFechamento = credito && fechamento.value.trim() === ""
    const inputVencimento = credito && vencimento.value.trim() === ""

    if (inputNome || inputConta || inputFechamento || inputVencimento) {
        notfy.error({
            message: "Os campos destacados não foram preenchidos corretamente!",
            icon: true,
            duration: 5000,
            position: { x: 'center', y: 'top' }
        })
        if (inputNome) nome.style.borderColor = "red"
        if (inputConta) conta.style.borderColor = "red"
        if (inputFechamento) fechamento.style.borderColor = "red"
        if (inputVencimento) vencimento.style.borderColor = "red"
        return
    }

    fetch('/cartoes/alterar', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            id: id.value,
            nome: nome.value,
            tipo: tipo.value,
            status: status.value,
            conta: conta.value,
            limite: limite.value,
            fechamento: fechamento.value,
            vencimento: vencimento.value
        })
    })
        .then(r => r.json())
        .then(r => {
            if (r.ok) {
                notfy.success({
                    message: "Sucesso! Cartão alterado.",
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

function deletarCartao() {
    let id = document.getElementById('car-edit-id')
    Swal.fire({
        title: "Tem certeza?",
        text: "As faturas desse cartão serão excluídas e as compras dele ficarão sem cartão!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Sim, deletar!"
    }).then((result) => {
        if (result.isConfirmed) {
            fetch('/cartoes/deletar', {
                method: 'POST',
                headers: { 'Content-type': 'application/json' },
                body: JSON.stringify({ id: id.value })
            })
                .then(r => r.json())
                .then(r => {
                    if (r.ok) {
                        Swal.fire({
                            title: `Cartão excluído!`,
                            text: `O cartão foi deletado com sucesso.`,
                            icon: "success"
                        });
                        setTimeout(() => {
                            window.location.reload()
                        }, 3000)
                    } else {
                        Swal.fire({
                            title: "Erro ao excluir cartão...",
                            text: r.msg,
                            icon: "error"
                        })
                    }
                })
        }
    });
}
