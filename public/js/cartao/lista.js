document.addEventListener("DOMContentLoaded", function(){
    const btn = document.querySelectorAll('.credit-card')
    btn.forEach( b =>{ b.addEventListener("click",exibirInfo) })
})
async function exibirInfo(){
    const dados = await fetch("/cartoes/listar",{body:JSON.stringify({id: data.set.id})})
    const result = await dados

}