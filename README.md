# Onebitexchange

Aplicacao Rails simples para simular conversao de moedas. A tela principal fica
em `GET /` e a conversao e feita em `GET /convert`, usando uma API externa de
cotacao configurada nas credentials do Rails.

## Versoes principais

- Ruby 2.6.5
- Rails 6.0.3.3
- PostgreSQL 16 Alpine via Docker
- Node 12 / Yarn
- Webpacker 4

## Como rodar localmente com Docker

Requisitos locais:

- Docker
- Docker Compose

Suba a aplicacao:

```bash
docker compose build
docker compose up
```

Acesse:

```text
http://localhost:3000
```

O container da aplicacao executa o `start.sh`, que:

- instala as gems com Bundler, se necessario;
- cria um Gemfile temporario para contornar a gem `mimemagic 0.3.5`, que foi removida do RubyGems;
- instala as dependencias JavaScript com Yarn;
- aguarda o PostgreSQL aceitar conexoes;
- remove PID antigo do Rails;
- executa `rails db:prepare`;
- inicia o Puma em `0.0.0.0:3000`.

Para parar:

```bash
docker compose down
```

Para remover tambem os volumes locais de banco, gems e `node_modules`:

```bash
docker compose down -v
```

Ao trocar a versao principal do PostgreSQL usada pelo Compose, pode ser
necessario recriar o volume local do banco com `docker compose down -v`.

## Banco de dados

O projeto usa PostgreSQL, mas atualmente nao possui tabelas de negocio
relevantes. O schema apenas habilita a extensao padrao `plpgsql`.

O banco de desenvolvimento usado pelo Rails e:

```text
onebit_exchange_development
```

## Credentials e API de cambio

A tela inicial pode abrir sem configurar a API externa. A conversao real em
`/convert` depende destas chaves nas credentials do Rails:

```yaml
currency_api_url: "URL_DA_API"
currency_api_key: "CHAVE_DA_API"
```

Esses valores sao lidos em `app/services/exchange_service.rb`.

Se voce nao possui mais o `config/master.key` original, nao e possivel
descriptografar o `config/credentials.yml.enc` atual. Para desenvolvimento,
sera necessario recriar credentials locais com uma nova chave antes de testar a
conversao real.

Este README nao troca a API de cambio nem define uma API nova.

## Comandos uteis

Abrir um shell no container da aplicacao:

```bash
docker compose run --rm app bash
```

Preparar o banco manualmente:

```bash
docker compose run --rm app bundle exec rails db:prepare
```

Rodar os testes:

```bash
docker compose run --rm app bundle exec rspec
```

## Observacoes

Este e um projeto Rails antigo. As instrucoes acima mantem Ruby, Rails,
Webpacker, Bootstrap e a arquitetura original, sem modernizacao.

O `Gemfile.lock` original referencia `mimemagic 0.3.5`, versao que nao esta
mais disponivel no RubyGems. Para permitir execucao local sem alterar o lockfile
do repositorio, o `start.sh` copia `Gemfile` e `Gemfile.lock` para `/tmp` dentro
do container e atualiza apenas essa copia temporaria para uma versao disponivel
da `mimemagic`.
