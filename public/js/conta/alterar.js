document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('btn-salvar-edicao').addEventListener('click', alterar)
    document.getElementById('btn-excluir-conta').addEventListener('click', deletar)
})

function alterar() {
    let id = document.getElementById('edit-id')
    let nome = document.getElementById('edit-nome')
    let tipo = document.getElementById('edit-tipo')
    let saldo = document.getElementById('edit-saldo')
    let pix = document.getElementById('edit-pix')
    let cor = document.getElementById('edit-cor')

    const notfy = new Notyf()

    id.style.borderColor = "green"
    nome.style.borderColor = "green"
    tipo.style.borderColor = "green"
    saldo.style.borderColor = "green"
    pix.style.borderColor = "green"

    const inputNome = nome.value.trim() === ""
    const inputTipo = tipo.value.trim() === ""
    const inputSaldo = saldo.value === ""
    const inputPix = pix.value.trim() === ""

    if (inputNome && inputTipo && inputSaldo) {
        nome.style.borderColor = "red"
        tipo.style.borderColor = "red"
        saldo.style.borderColor = "red"
        pix.style.borderColor = "red"
        notfy.error({
            message: "Preencha todos os campos!",
            icon: true,
            duration: 3000,
            position: { x: 'center', y: 'top' }
        })
    }
    if (inputNome || inputTipo || inputSaldo) {
        notfy.error({
            message: "Os campos destacados não foram preenchidos corretamente!",
            icon: true,
            duration: 5000,
            position: { x: 'center', y: 'top' }
        })
        if (inputNome) nome.style.borderColor = "red"
        if (inputTipo) tipo.style.borderColor = "red"
        if (inputSaldo) saldo.style.borderColor = "red"
    }

    if (!inputNome && !inputSaldo && !inputTipo) {
        fetch('/contas/alterar', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                id: id.value,
                nome: nome.value,
                tipo: tipo.value,
                pix: pix.value,
                saldo: saldo.value,
                cor: cor.value
            })
        })
            .then(r => r.json())
            .then(r => {
                if (r.ok) {
                    notfy.success({
                        message: "Sucesso! Conta alterada.",
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
    let id = document.getElementById('edit-id')
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
            fetch('/contas/deletar', {
                method: 'POST',
                headers: { 'Content-type': 'applicatin/json' },
                body: JSON.stringify({ id: id.value })
            })
                .then(r => r.json())
                .then(r => {
                    if (r.ok) {
                        Swal.fire({
                            title: `Conta ${r.conta} excluida!`,
                            text: `A conta foi deletada com sucesso.`,
                            icon: "success"
                        });
                        setTimeout(()=>{
                            window.location.reload()
                        },3000)
                    }else{
                        Swal.fire({
                            title:"Erro ao excluir conta...",
                            text:r.msg,
                            icon:"error"
                        })
                    }
                })
        }
    });
}