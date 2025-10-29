#!/bin/bash
# ==========================================================
# Script de instalação e configuração do ambiente Java
# ==========================================================

# --- Função: checa se está executando como root ---
if [ "$EUID" -ne 0 ]; then
  echo " Execute este script como root (use: sudo ./install_java_env.sh)"
  exit 1
fi

echo "Iniciando instalação do ambiente Java..."
echo "==========================================="

# --- Atualizando pacotes ---
echo "Atualizando lista de pacotes..."
apt update -y && apt upgrade -y

# --- Instalando dependências básicas ---
echo "Instalando pacotes essenciais..."
apt install -y wget curl unzip zip git software-properties-common

# --- Função para verificar programas ---
check_installed() {
  if command -v "$1" &> /dev/null; then
    echo "$1 já está instalado ($(which $1))"
    return 0
  else
    echo "$1 não encontrado, instalando..."
    return 1
  fi
}

# ==========================================================
# INSTALAÇÃO DO JAVA
# ==========================================================
check_installed java
if [ $? -ne 0 ]; then
  echo "Instalando OpenJDK 21..."
  apt install -y openjdk-21-jdk
else
  echo "Versão atual do Java:"
  java -version
fi

# --- Configurando variáveis de ambiente ---
echo "Configurando variáveis de ambiente..."
JAVA_PATH=$(update-alternatives --query java | grep "Value:" | awk '{print $2}' | sed 's/\/bin\/java//')

if [ -z "$JAVA_PATH" ]; then
  echo "Não foi possível detectar o caminho do JAVA_HOME automaticamente."
  JAVA_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
fi

# Cria ou atualiza o arquivo de variáveis
cat <<EOF > /etc/profile.d/java.sh
export JAVA_HOME=$JAVA_PATH
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

chmod +x /etc/profile.d/java.sh
source /etc/profile.d/java.sh

echo "Variáveis de ambiente configuradas:"
echo "JAVA_HOME = $JAVA_HOME"

# ==========================================================
# MAVEN
# ==========================================================
check_installed mvn
if [ $? -ne 0 ]; then
  echo "Instalando Apache Maven..."
  apt install -y maven
else
  mvn -version
fi

# ==========================================================
# GRADLE
# ==========================================================
check_installed gradle
if [ $? -ne 0 ]; then
  echo "Instalando Gradle..."
  wget -q https://services.gradle.org/distributions/gradle-8.7-bin.zip -P /tmp
  unzip -q -d /opt/gradle /tmp/gradle-8.7-bin.zip
  echo "export GRADLE_HOME=/opt/gradle/gradle-8.7" >> /etc/profile.d/java.sh
  echo 'export PATH=$PATH:$GRADLE_HOME/bin' >> /etc/profile.d/java.sh
  source /etc/profile.d/java.sh
else
  gradle -v
fi

# ==========================================================
# VERIFICAÇÕES FINAIS
# ==========================================================
echo
echo "==========================================="
echo "Verificação final das instalações:"
echo "-------------------------------------------"
echo "Java:"
java -version
echo
echo "Maven:"
mvn -version
echo
echo "Gradle:"
gradle -v
echo "-------------------------------------------"
echo "Ambiente Java configurado com sucesso!"
echo "Dica: use 'source /etc/profile.d/java.sh' para ativar as variáveis agora."
echo "==========================================="
