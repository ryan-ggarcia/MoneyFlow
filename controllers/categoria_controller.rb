class App < Sinatra::Base
    get "/categorias" do
            erb :"categoria/listar"
    end
    get "/categorias/cadastrar" do 
            erb :"categoria/cadastrar"
    end
end