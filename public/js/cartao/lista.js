document.addEventListener("DOMContentLoaded", function(){
    const btn = document.querySelectorAll('.credit-card')
    btn.forEach( b =>{ b.addEventListener("click",exibirInfo) })
})
async function exibirInfo(){
    let divInforCartao = document.getElementById("cartao-info")

    const dados = await fetch(`/cartoes/listar/${this.dataset.id}`)
    const buscarCartao = await dados.json()
    console.log(buscarCartao.cartoes[0])
    if (buscarCartao.length == 0){
        window.location.reload()
    }else{
        divInforCartao.innerHTML = montarDiv(buscarCartao.cartoes[0])
    }
}

function montarDiv(cartao){
    if(cartao["car_tipo"] == "CREDITO"){
         return `
             <!-- Coluna esquerda: uso do limite + datas -->
                <div class="flex flex-col gap-md">
                <!-- Uso do limite -->
                <div class="card">
                <div class="flex items-center justify-between flex-wrap gap-xs mb-sm">
                    <h3 class="text-headline-md text-on-surface">Uso do Limite</h3>
                    <div class="flex items-center gap-1 text-tertiary px-3 py-1 bg-error-container rounded-full">
                    <span class="material-symbols-outlined text-sm" style="font-variation-settings: 'FILL' 1;">warning</span>
                    <span class="text-label-md">Alerta: próximo ao limite</span>
                    </div>
                </div>
                <div class="flex flex-col gap-base">
                    <div class="flex justify-between text-on-surface-variant">
                    <span class="text-label-lg">Limite Utilizado</span>
                    <span class="text-label-lg font-bold">R$ 14.820,00</span>
                    </div>
                    <!-- Barra de progresso -->
                    <div class="h-3 w-full bg-surface-variant rounded-full overflow-hidden">
                    <div class="h-full bg-tertiary rounded-full transition-all duration-1000 ease-out" style="width: 82%;"></div>
                    </div>
                    <div class="flex justify-between text-on-surface-variant">
                    <span class="text-label-md">Disponível: R$ ${parseFloat(cartao["car_limite"])}</span>
                    <span class="text-label-md">Total: R$ ${parseFloat(cartao["car_limite"])}</span>
                    </div>
                </div>
                </div>

                <!-- Datas de fechamento e vencimento -->
                <div class="grid grid-cols-2 gap-gutter">
                <div class="card flex flex-col gap-xs">
                    <span class="material-symbols-outlined text-secondary">event_repeat</span>
                    <p class="text-label-md text-on-surface-variant uppercase">Fechamento</p>
                    <p class="text-headline-md text-on-surface">Todo dia ${cartao["car_fechamento"]}</p>
                </div>
                <div class="card flex flex-col gap-xs">
                    <span class="material-symbols-outlined text-error">calendar_today</span>
                    <p class="text-label-md text-on-surface-variant uppercase">Vencimento</p>
                    <p class="text-headline-md text-on-surface">Todo dia ${cartao["car_validade"]}</p>
                </div>
                </div>
                </div>

                <!-- Coluna direita: últimas compras do cartão -->
                <div class="card">
                <div class="flex justify-between items-center mb-md">
                    <h3 class="text-headline-md text-on-surface">Últimas Compras</h3>
                    <button class="link-accent text-label-lg" type="button">Ver tudo</button>
                </div>
                <div class="flex flex-col gap-sm">
                    <div class="flex items-center gap-4 py-2">
                    <div class="icon-circle rounded-lg w-10 h-10 bg-surface-container text-on-surface-variant">
                        <span class="material-symbols-outlined">shopping_cart</span>
                    </div>
                    <div class="flex-1">
                        <p class="text-label-lg text-on-surface">Apple Store Brasil</p>
                        <p class="text-label-md text-on-surface-variant">Hoje, 14:20</p>
                    </div>
                    <p class="text-label-lg font-bold text-on-surface">- R$ 12.499,00</p>
                    </div>
                    <div class="h-px bg-surface-variant w-full"></div>
                    <div class="flex items-center gap-4 py-2">
                    <div class="icon-circle rounded-lg w-10 h-10 bg-surface-container text-on-surface-variant">
                        <span class="material-symbols-outlined">restaurant</span>
                    </div>
                    <div class="flex-1">
                        <p class="text-label-lg text-on-surface">Restaurante Fasano</p>
                        <p class="text-label-md text-on-surface-variant">Ontem, 21:05</p>
                    </div>
                    <p class="text-label-lg font-bold text-on-surface">- R$ 450,00</p>
                    </div>
                </div>
                </div>
        `
    }else{
        return `
             <!-- Coluna esquerda: uso do limite + datas -->
                <div class="flex flex-col gap-md">
                <!-- Coluna direita: últimas compras do cartão -->
                <div class="card">
                <div class="flex justify-between items-center mb-md">
                    <h3 class="text-headline-md text-on-surface">Últimas Compras</h3>
                    <button class="link-accent text-label-lg" type="button">Ver tudo</button>
                </div>
                <div class="flex flex-col gap-sm">
                    <div class="flex items-center gap-4 py-2">
                    <div class="icon-circle rounded-lg w-10 h-10 bg-surface-container text-on-surface-variant">
                        <span class="material-symbols-outlined">shopping_cart</span>
                    </div>
                    <div class="flex-1">
                        <p class="text-label-lg text-on-surface">Apple Store Brasil</p>
                        <p class="text-label-md text-on-surface-variant">Hoje, 14:20</p>
                    </div>
                    <p class="text-label-lg font-bold text-on-surface">- R$ 12.499,00</p>
                    </div>
                    <div class="h-px bg-surface-variant w-full"></div>
                    <div class="flex items-center gap-4 py-2">
                    <div class="icon-circle rounded-lg w-10 h-10 bg-surface-container text-on-surface-variant">
                        <span class="material-symbols-outlined">restaurant</span>
                    </div>
                    <div class="flex-1">
                        <p class="text-label-lg text-on-surface">Restaurante Fasano</p>
                        <p class="text-label-md text-on-surface-variant">Ontem, 21:05</p>
                    </div>
                    <p class="text-label-lg font-bold text-on-surface">- R$ 450,00</p>
                    </div>
                </div>
                </div>
        `
    }
}