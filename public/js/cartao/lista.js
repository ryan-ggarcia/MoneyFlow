document.addEventListener("DOMContentLoaded", function(){
    const btn = document.querySelectorAll('.credit-card')
    btn.forEach( b =>{ b.addEventListener("click",exibirInfo) })
})

function moeda(valor){
    return Number(valor).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
}

async function exibirInfo(){
    let divInforCartao = document.getElementById("cartao-info")

    const dados = await fetch(`/cartoes/listar/${this.dataset.id}`)
    const detalhe = await dados.json()
    if (!detalhe.ok){
        window.location.reload()
    }else{
        divInforCartao.innerHTML = montarDiv(detalhe)
        ligarPagamento()
    }
}

function ligarPagamento(){
    document.querySelectorAll('.js-pagar-fatura').forEach(botao => {
        botao.addEventListener('click', () => pagarFatura(botao.dataset.id))
    })
}

function pagarFatura(id){
    const notfy = new Notyf()
    fetch('/faturas/pagar', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id })
    })
        .then(r => r.json())
        .then(r => {
            if (r.ok) {
                notfy.success({
                    message: "Fatura paga!",
                    icon: true,
                    duration: 3000,
                    position: { x: 'center', y: 'top' }
                })
                setTimeout(() => { window.location.reload() }, 2000)
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

function montarDiv(detalhe){
    if(detalhe.cartao["car_tipo"] == "CREDITO"){
        return montarCredito(detalhe) + montarCompras(detalhe.compras)
    }
    return montarDebito(detalhe)
}

function montarDebito(detalhe){
    return `
        <div class="card">
        <h3 class="text-headline-md text-on-surface mb-sm">Cartão de débito</h3>
        <p class="text-body-md text-on-surface-variant">
            No débito não existe fatura: o valor sai na hora da conta
            <span class="font-bold">${detalhe.cartao["con_nome"]}</span> e a compra aparece nas suas
            <a class="link-accent" href="/movimentacoes">movimentações</a>.
        </p>
        </div>
    `
}

// Uso do limite, datas do cartão e as faturas em aberto
function montarCredito(detalhe){
    const limite = parseFloat(detalhe.cartao["car_limite"]) || 0
    const usado = parseFloat(detalhe.usado) || 0
    const disponivel = limite - usado
    const percentual = limite > 0 ? Math.min(Math.round(usado / limite * 100), 100) : 0
    const alerta = percentual >= 80

    return `
        <div class="flex flex-col gap-md">
        <div class="card">
        <div class="flex items-center justify-between flex-wrap gap-xs mb-sm">
            <h3 class="text-headline-md text-on-surface">Uso do Limite</h3>
            ${alerta ? `
            <div class="flex items-center gap-1 text-tertiary px-3 py-1 bg-error-container rounded-full">
            <span class="material-symbols-outlined text-sm" style="font-variation-settings: 'FILL' 1;">warning</span>
            <span class="text-label-md">Alerta: próximo ao limite</span>
            </div>` : ''}
        </div>
        <div class="flex flex-col gap-base">
            <div class="flex justify-between text-on-surface-variant">
            <span class="text-label-lg">Limite Utilizado</span>
            <span class="text-label-lg font-bold">${moeda(usado)}</span>
            </div>
            <div class="h-3 w-full bg-surface-variant rounded-full overflow-hidden">
            <div class="h-full ${alerta ? 'bg-tertiary' : 'bg-primary'} rounded-full transition-all duration-1000 ease-out" style="width: ${percentual}%;"></div>
            </div>
            <div class="flex justify-between text-on-surface-variant">
            <span class="text-label-md">Disponível: ${moeda(disponivel)}</span>
            <span class="text-label-md">Total: ${moeda(limite)}</span>
            </div>
        </div>
        </div>

        <div class="grid grid-cols-2 gap-gutter">
        <div class="card flex flex-col gap-xs">
            <span class="material-symbols-outlined text-secondary">event_repeat</span>
            <p class="text-label-md text-on-surface-variant uppercase">Fechamento</p>
            <p class="text-headline-md text-on-surface">Todo dia ${detalhe.cartao["car_fechamento"]}</p>
        </div>
        <div class="card flex flex-col gap-xs">
            <span class="material-symbols-outlined text-error">calendar_today</span>
            <p class="text-label-md text-on-surface-variant uppercase">Vencimento</p>
            <p class="text-headline-md text-on-surface">Todo dia ${detalhe.cartao["car_validade"]}</p>
        </div>
        </div>

        ${montarFaturas(detalhe.faturas)}
        </div>
    `
}

function montarFaturas(faturas){
    if (!faturas.length) return ''

    const linhas = faturas.map(f => `
        <div class="flex items-center gap-4 py-2">
        <div class="icon-circle rounded-lg w-10 h-10 ${f.fat_pago ? 'bg-primary/10 text-primary' : 'bg-surface-container text-on-surface-variant'}">
            <span class="material-symbols-outlined">${f.fat_pago ? 'check_circle' : 'receipt_long'}</span>
        </div>
        <div class="flex-1 min-w-0">
            <p class="text-label-lg text-on-surface truncate">${f.fat_nome}</p>
            <p class="text-label-md text-on-surface-variant">Vence em ${f.fat_data}</p>
        </div>
        <div class="text-right">
            <p class="text-label-lg font-bold text-on-surface whitespace-nowrap">${moeda(f.fat_total)}</p>
            ${f.fat_pago
                ? '<span class="text-label-md text-primary">Paga</span>'
                : `<button class="js-pagar-fatura link-accent text-label-md cursor-pointer" type="button" data-id="${f.fat_id}">Pagar</button>`}
        </div>
        </div>
    `).join('<div class="h-px bg-surface-variant w-full"></div>')

    return `
        <div class="card">
        <h3 class="text-headline-md text-on-surface mb-md">Faturas</h3>
        <div class="flex flex-col gap-sm">${linhas}</div>
        </div>
    `
}

function montarCompras(compras){
    if (!compras.length){
        return `
            <div class="card">
            <h3 class="text-headline-md text-on-surface mb-md">Últimas Compras</h3>
            <p class="text-body-md text-on-surface-variant">Nenhuma compra lançada nesse cartão ainda.</p>
            </div>
        `
    }

    const linhas = compras.map(c => `
        <div class="flex items-center gap-4 py-2">
        <div class="icon-circle rounded-lg w-10 h-10 bg-surface-container text-on-surface-variant">
            <span class="material-symbols-outlined">shopping_cart</span>
        </div>
        <div class="flex-1 min-w-0">
            <p class="text-label-lg text-on-surface truncate">${c.mov_nome}${c.mov_parcela_total > 1 ? ` (${c.mov_parcela}/${c.mov_parcela_total})` : ''}</p>
            <p class="text-label-md text-on-surface-variant">${c.mov_data}${c.cat_nome ? ` · ${c.cat_nome}` : ''}</p>
        </div>
        <p class="text-label-lg font-bold text-on-surface whitespace-nowrap">- ${moeda(c.mov_valor)}</p>
        </div>
    `).join('<div class="h-px bg-surface-variant w-full"></div>')

    return `
        <div class="card">
        <div class="flex justify-between items-center mb-md">
            <h3 class="text-headline-md text-on-surface">Últimas Compras</h3>
            <a class="link-accent text-label-lg" href="/movimentacoes">Ver tudo</a>
        </div>
        <div class="flex flex-col gap-sm">${linhas}</div>
        </div>
    `
}
