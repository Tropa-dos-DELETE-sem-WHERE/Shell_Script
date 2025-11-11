#!/bin/bash
# -----------------------------------------------------------------------------
# SCRIPT DE CONFIGURAÇÃO DE AMBIENTE
#
# Este script prepara o ambiente com 3 focos:
# 1. Instalação do Java 21 JRE (se necessário)
# 2. Informação sobre as Dependências (Libs) do projeto
# 3. Criação do script de execução com as Variáveis de Ambiente
#
# PRÉ-REQUISITO:
#   - Este script deve ser executado com 'sudo' (ex: sudo ./setup_ambiente.sh)
#   - O 'aplicacao.jar' deve ser colocado manualmente em /home/ubuntu/Jar
# -----------------------------------------------------------------------------

# --- 0. VALIDAÇÃO DE PERMISSÃO ---
if [ "$EUID" -ne 0 ]; then
  echo "Erro: Este script precisa ser executado com 'sudo' para instalar o Java."
  echo "Execute: sudo ./setup_ambiente.sh"
  exit 1
fi

# --- CONFIGURAÇÕES GLOBAIS (EDITE SE NECESSÁRIO) ---
APP_DIR="/home/ubuntu/Jar"
RUN_SCRIPT_PATH="$APP_DIR/run_job.sh"
LOG_FILE="$APP_DIR/cron_job.log"

# Credenciais do Banco
DB_ENDPOINT="172.31.41.5"
DB_USER_VAL="Caramico"
DB_PASS_VAL="urubu100"

# -----------------------------------------------------------------------------
# Início do Script
# -----------------------------------------------------------------------------

echo "Iniciando script de setup (Java, Dependências, Variáveis)..."


# --- 1. INSTALAÇÃO JAVA ---
echo -e "\n### 1/3: Verificando Instalação do Java 21..."

# 2>&1 redireciona stderr para stdout, -q silencia o grep
if ! java -version 2>&1 | grep -q "21."; then
    echo "Java 21 não encontrado. Instalando openjdk-21-jre-headless..."
    
    # Tenta usar 'apt-get' (Ubuntu/Debian)
    if command -v apt-get &> /dev/null; then
        apt-get update -y
        apt-get install -y openjdk-21-jre-headless
    # Tenta usar 'yum' (Amazon Linux/RHEL)
    elif command -v yum &> /dev/null; then
        yum install -y java-21-amazon-corretto-headless
    else
        echo "Erro: Gerenciador de pacotes (apt ou yum) não encontrado."
        echo "Por favor, instale o Java 21 manualmente."
        exit 1
    fi
    
    echo "Java 21 JRE instalado com sucesso."
else
    echo "Java 21 já está instalado."
    java -version
fi


# --- 2. DEPENDÊNCIAS UTILIZADAS (LIBS) ---
echo -e "\n### 2/3: Verificando Dependências Utilizadas (Libs)..."
echo "As 'libs' (dependências Java) do seu projeto são gerenciadas pelo Maven."
echo "Com base no seu 'pom.xml', elas já estão 'empacotadas' dentro do 'aplicacao.jar'."
echo ""
echo "NENHUMA instalação de 'libs' é necessária no servidor."
echo "As dependências principais do projeto são:"
echo "  - MySQL Connector/J (para o banco de dados)"
echo "  - Apache POI (poi, poi-ooxml) (para leitura de arquivos Excel)"
echo "  - AWS S3 SDK (s3) (para baixar arquivos do S3)"
echo ""


# --- 3. VARIÁVEIS DE AMBIENTE ---
echo -e "\n### 3/3: Configurando Variáveis de Ambiente..."
echo "As variáveis de ambiente serão salvas dentro do script de execução."

# Garante que o diretório de destino exista
mkdir -p "$APP_DIR"
echo "Diretório $APP_DIR verificado/criado."

if [ ! -f "$RUN_SCRIPT_PATH" ]; then
    echo "Script $RUN_SCRIPT_PATH não encontrado. Criando..."
    
    # Usa 'cat' com 'EOF' para escrever o conteúdo no arquivo
    cat << EOF > "$RUN_SCRIPT_PATH"
#!/bin/bash

# --- 1. CONFIGURAÇÃO DAS VARIÁVEIS DE AMBIENTE ---
# Estas variáveis são lidas pelo aplicacao.jar
export DB_URL="jdbc:mysql://${DB_ENDPOINT}:3306/educadata"
export DB_USER="${DB_USER_VAL}"
export DB_PASSWORD="${DB_PASS_VAL}"

# --- 2. CONFIGURAÇÃO DOS CAMINHOS ---
JAVA_EXEC="/usr/bin/java" 
APP_DIR="${APP_DIR}"
JAR_NAME="aplicacao.jar"
LOG_FILE="${LOG_FILE}"

# --- 3. EXECUÇÃO ---
cd \${APP_DIR}

echo "--- [\$(date)] Iniciando job (via cron) ---" >> \${LOG_FILE}
\${JAVA_EXEC} -jar \${JAR_NAME} >> \${LOG_FILE} 2>&1
echo "--- [\$(date)] Job finalizado ---" >> \${LOG_FILE}
EOF

    # Torna o script recém-criado executável
    chmod +x "$RUN_SCRIPT_PATH"
    echo "Script $RUN_SCRIPT_PATH criado com sucesso."
else
    echo "Script $RUN_SCRIPT_PATH já existe."
    echo "As variáveis de ambiente não foram alteradas para evitar sobrescrever mudanças."
    echo "Para atualizar, edite o arquivo manualmente: nano $RUN_SCRIPT_PATH"
fi

echo -e "\n----------------------------------------"
echo "✅ Setup de ambiente concluído!"
echo "IMPORTANTE: Lembre-se de colocar o 'aplicacao.jar' em $APP_DIR."
echo "----------------------------------------"