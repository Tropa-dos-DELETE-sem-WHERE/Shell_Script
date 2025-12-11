#!/bin/bash

# Cores para facilitar a leitura
VERDE='\033[0;32m'
SEM_COR='\033[0m'

echo -e "${VERDE}=========================================================${SEM_COR}"
echo -e "${VERDE}>>> PREPARANDO AMBIENTE UBUNTU (JAVA 21) <<<${SEM_COR}"
echo -e "${VERDE}=========================================================${SEM_COR}"

# ----------------------------------------------------------------------
# 1. ATUALIZAÇÃO DO SISTEMA (APT)
# ----------------------------------------------------------------------
echo "[1/3] Atualizando repositórios (apt update)..."
# -y aceita confirmações automaticamente
# DEBIAN_FRONTEND=noninteractive evita janelas de configuração travando o script
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get upgrade -y

# ----------------------------------------------------------------------
# 2. INSTALAÇÃO DO JAVA 21 (OPENJDK)
# ----------------------------------------------------------------------
echo "[2/3] Verificando e Instalando Java 21..."

if type -p java > /dev/null; then
    echo "Java já detectado. Verificando versão..."
else
    echo "Nenhum Java detectado. Instalando OpenJDK 21..."
fi

# Instala o OpenJDK 21 (Padrão do Ubuntu para Java 21)
# O "-headless" é a versão leve para servidores (sem interface gráfica)
sudo apt-get install openjdk-21-jdk-headless -y

# ----------------------------------------------------------------------
# 3. VALIDAÇÃO FINAL
# ----------------------------------------------------------------------
echo "[3/3] Validando instalação..."

if type -p java > /dev/null; then
    JAVA_VERSAO=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    CAMINHO_JAVA=$(which java)
    
    echo -e "${VERDE}>>> SUCESSO! O ambiente está pronto.${SEM_COR}"
    echo "Versão do Java: $JAVA_VERSAO"
    echo "Caminho do executável: $CAMINHO_JAVA"
    echo "---------------------------------------------------------"
else
    echo ">>> ERRO CRÍTICO: O Java não foi instalado corretamente."
    exit 1
fi