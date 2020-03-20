
# Sorteio Zoom Meeting

Este projeto pretende criar uma interface web simples para listar meetings do `zoom.us` e trazer a possibilidade de
escolher de forma randômica de um dos participantes da meeting.

Pode ser utilizados para sortear participantes para as mais diversas dinâmicas

## Instalando

Clone este repositório:

`git clone git@github.com:dvinciguerra/sorteio-zoom-meeting.git`

### Local

_Passos para subir o projeto no ambiente local:_

#### Ngrok

* Instale o ngrok
* Abra um terminal para a porta desejada (`ngrok http 5000`)
* Copie o endereço gerado e reserve

#### Crie uma conta de dev

* Crie uma conta de desenvolvimento para integração do tipo Chat em [https://marketplace.zoom.us](https://marketplace.zoom.us)
* Use o endereço do `ngrok` gerado no passo acima
* Com a conta criada, copie o `Client ID` e o `Client Secret`

#### Subindo a aplicação

* Instale as dependências do projeto (`bundle install`)
* Crie um arquivo chamado `.env` baseado no template `env.development` (use o endereço do ngrok e dados da conta)
* Suba a aplicação usando (`foreman start`)

#### Acessando

* Use a url gerada na guia `Local Test` da conta de integração gerada do zoom em `https://marketplace.zoom.us`


