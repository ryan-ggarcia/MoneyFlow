document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("btn").addEventListener("click", register)
})
function pegarCategoria(){
    let resceita = document.getElementById("resceita")
    let despesa = document.getElementById("despesa")
    const inputResceita = resceita.value != "0"
    return inputResceita ? resceita : despesa
}
function register() {
    let nome = document.getElementById("nome")
    let valor = document.getElementById("valor")
    let data = document.getElementById("data")
    let conta = document.getElementById("conta")
    let categoria = pegarCategoria()
    let tipo = document.getElementById("tipo")
    let cartao = document.getElementById("cartao")
    let parcelas = document.getElementById("parcelas")
    const notfy = new Notyf()

    const usaCartao = cartao.value != "0"
    const inputNome = nome.value.trim() == ""
    const inputValor = valor.value.trim() == ""
    const inputData = data.value == ""
    const inputConta = !usaCartao && conta.value == "0"
    const inputCategoria = categoria.value == "0"
    const inputTipo = tipo.value == "0"

    nome.style.borderColor = "green"
    valor.style.borderColor = "green"
    data.style.borderColor = "green"
    conta.style.borderColor = "green"
    categoria.style.borderColor = "green"
    tipo.style.borderColor = "green"

    if (inputNome || inputValor || inputData || inputConta || inputCategoria || inputTipo) {
        notfy.error({
            message: "Preencha todos os campos!",
            icon: true,
            duration: 3000,
            position: { x: 'center', y: 'top' }
        })
        if (inputNome) nome.style.borderColor = "red"
        if (inputValor) valor.style.borderColor = "red"
        if (inputData) data.style.borderColor = "red"
        if (inputConta) conta.style.borderColor = "red"
        if (inputTipo) tipo.style.borderColor = "red"
        if (inputCategoria) categoria.style.borderColor = "red"
    }
    if (!inputNome && !inputValor && !inputData && !inputConta && !inputCategoria && !inputTipo) {
        fetch("/movimentacoes/efetuarCadastro", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                nome: nome.value,
                valor: valor.value,
                data: data.value,
                conta: conta.value,
                categoria: categoria.value,
                tipo: tipo.value,
                cartao: cartao.value,
                parcelas: parcelas.value
            })
        })
            .then(r => r.json())
            .then(r => {
                if (r.ok) {
                    notfy.success({
                        message: "Sucesso! Receita cadastrada.",
                        icon: true,
                        duration: 3000,
                        position: { x: 'center', y: 'top' }
                    })
                    setTimeout(() => { window.location.href = '/movimentacoes' }, 4000)
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