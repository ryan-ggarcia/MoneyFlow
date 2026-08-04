document.addEventListener('DOMContentLoaded', function () {
    const backdrop = document.getElementById('mov-backdrop')
    const sheet = document.getElementById('mov-sheet')

    function abrir(dados) {
        document.getElementById('mov-edit-id').value = dados.id || ''
        document.getElementById('mov-edit-nome').value = dados.nome || ''
        document.getElementById('mov-edit-valor').value = dados.valor || ''
        document.getElementById('mov-edit-data').value = dados.data || ''
        document.getElementById('mov-edit-conta').value = dados.conta || '0'
        document.getElementById('mov-edit-categoria').value = dados.categoria || '0'
        backdrop.classList.add('is-open')
        sheet.classList.add('is-open')
        sheet.setAttribute('aria-hidden', 'false')
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
    let categoria = document.getElementById('mov-edit-categoria')

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
                        message: "Sucesso! Receita alterada.",
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
    Swal.fire({
        title: "Tem certeza?",
        text: "Você não conseguirá reverter isso!",
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
