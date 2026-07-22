document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("btn").addEventListener("click", register)
})

function register() {
    let nome = document.getElementById("nome")
    let limite = document.getElementById("limite")
    let diaFechamento = document.getElementById("dia_fechamento")
    let diaVencimento = document.getElementById("dia_vencimento")

    nome.style.borderColor = "green"
    limite.style.borderColor = "green"
    diaFechamento.style.borderColor = "green"
    diaVencimento.style.borderColor = "green"

    const inputNome = nome.ariaValueMax.trim() === ""
    const inputLimite = limite.ariaValueMax.trim() === ""
    const inputClouse = diaFechamento.ariaValueMax.trim() === ""
    const inputVencimento = diaVencimento.ariaValueMax.trim() === ""

    const notfy = new Notyf()

    if (inputNome || inputLimite || inputClouse || inputVencimento) {
        notfy.error({
            message: "Os campos destacados não foram preenchidos corretamente!",
            icon: true,
            duration: 5000,
            position: { x: 'center', y: 'top' }
        })
        if(inputNome) nome.style.borderColor = "red"
        if(inputLimite) limite.style.borderColor = "red"
        if(inputClouse) diaFechamento.style.borderColor = "red"
        if(inputVencimento) diaVencimento.style.borderColor = "red"
    }
    if(!inputNome && !inputLimite && !inputClouse && !inputVencimento){
        
    }

}