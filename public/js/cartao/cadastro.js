document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("btn").addEventListener("click", register)
})

function register() {
    let nome = document.getElementById("nome")
    let limite = document.getElementById("limite")
    let diaFechamento = document.getElementById("dia_fechamento")
    let diaVencimento = document.getElementById("dia_vencimento")
    let tipo = document.getElementById("tipo")
    let conta = document.getElementById("conta")

    nome.style.borderColor = "green"
    tipo.style.borderColor = "green"
    conta.style.borderColor = "green"
    limite.style.borderColor = "green"
    diaFechamento.style.borderColor = "green"
    diaVencimento.style.borderColor = "green"

    const inputNome = nome.value.trim() === ""
    const inputTipo = tipo.value.trim() === ""
    const inputConta = conta.value === "0"
    const inputLimite = limite.value.trim() === ""
    const inputClouse = diaFechamento.value.trim() === ""
    const inputVencimento = diaVencimento.value.trim() === ""

    const notfy = new Notyf()

    if (inputNome || inputTipo || inputConta ) {
        notfy.error({
            message: "Os campos destacados não foram preenchidos corretamente!",
            icon: true,
            duration: 5000,
            position: { x: 'center', y: 'top' }
        })
        if (inputNome) nome.style.borderColor = "red"
        if (inputTipo) tipo.style.borderColor = "red"
        if (inputConta) conta.style.borderColor = "red"
    }
    if (!inputNome && !inputTipo && !inputConta) {
        fetch("/cartao/efetuarCadastro", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                nome: nome.value,
                tipo: tipo.value,
                limite: limite.value,
                fechamento: diaFechamento.value,
                vencimento: diaVencimento.value,
                conta: conta.value
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
                    setTimeout(() => { window.location.href = "/cartoes" }, 3000)
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
