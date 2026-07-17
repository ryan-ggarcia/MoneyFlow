document.addEventListener("DOMContentLoaded", function (e) {
    e.preventDefault()
    document.getElementById("btn").addEventListener("click", validar)
})

function validar() {
    let nome = document.getElementById("nome")
    let tipo = document.getElementById("tipo")
    let saldo = document.getElementById("saldo")
    let pix = document.getElementById("pix")
    let cor = document.getElementById("cor")
   
    const notfy = new Notyf()

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
        fetch('/contas/efetuarCadastro', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
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
                        message: "Sucesso! Conta cadastrada.",
                        icon: true,
                        duration: 3000,
                        position: { x: 'center', y: 'top' }
                    })
                    setTimeout(()=>{ window.location.href = '/contas' }, 4000)
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