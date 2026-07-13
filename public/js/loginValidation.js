document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("btn").addEventListener("click", validar)
})

function validar() {
    let user = document.getElementById('email')
    let senha = document.getElementById('senha')
    const notyf = new Notyf();

    user.style.borderColor = "green"
    senha.style.borderColor = "green"

    const emailVazio = user.value.trim() === ""
    const senhaVazia = senha.value.trim() === ""

    if (emailVazio && senhaVazia) {
        user.style.borderColor = "red"
        senha.style.borderColor = "red"
        notyf.error({
            duration: 3000,
            icon: true,
            message: "Preencha todos os campos obrigatórios!",
            position: { x: 'center', y: 'top' }
        })
        return // para aqui: não avalia mais nada
    }

    if (emailVazio || !user.value.includes('@')) {
        user.style.borderColor = "red"
        notyf.error({
            duration: 3000,
            icon: true,
            message: "E-mail inválido! Coloque o @.",
            position: { x: 'center', y: 'top' }
        })
        return
    }

    if (senhaVazia) {
        senha.style.borderColor = "red"
        notyf.error({
            duration: 3000,
            icon: true,
            message: "Senha inválida! Preencha a sua senha.",
            position: { x: 'center', y: 'top' }
        })
        return
    }
    fetch('/efetuarLogin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.parse({ user: user, senha: senha })
    })
        .then(r => { return r.json() })
        .then(r => {
            if (r.ok) {
                notyf.success({
                    duration: 3000,
                    icon: true,
                    message: "Bem-vindo de volta!",
                    position: { x: 'center', y: 'top' }
                })
                .then( window.location.href = '/' )
            }
        })

}