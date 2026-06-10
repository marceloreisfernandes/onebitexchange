set -e

# Usa um Gemfile temporario para contornar a gem mimemagic 0.3.5, removida do RubyGems.
# O Gemfile.lock do repositorio nao e alterado.
cp Gemfile /tmp/Gemfile
cp Gemfile.lock /tmp/Gemfile.lock
export BUNDLE_GEMFILE=/tmp/Gemfile

if grep -q "mimemagic (0.3.5)" /tmp/Gemfile.lock; then
  bundle update mimemagic --conservative
fi

# Instala as Gems
bundle check || bundle install

# Instala as dependencias JavaScript usadas pelo Webpacker
yarn install --check-files

# Aguarda o PostgreSQL aceitar conexoes antes de preparar o banco
until pg_isready -h db -U postgres; do
  echo "Aguardando PostgreSQL..."
  sleep 1
done

# Garante o diretorio de PID e remove PID antigo caso o container tenha sido encerrado sem limpeza
mkdir -p tmp/pids
rm -f tmp/pids/server.pid

# Cria/prepara o banco local quando necessario
bundle exec rails db:prepare

# Roda o servidor acessivel fora do container
bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:3000
