# 📥 Instalação Manual do Maven (Passo a Passo)

## Método Rápido: Usar o Script PowerShell

1. **Abra PowerShell como Administrador**
   - Clique com botão direito no PowerShell
   - Selecione "Executar como administrador"

2. **Execute o script**:
   ```powershell
   cd "E:\Arthur Trindade\Maua\Sistema-gestao-educacional-Professores-alunos---PI-4-semestre-1"
   .\INSTALAR_MAVEN_WINDOWS.ps1
   ```

3. **Feche e reabra o terminal**

4. **Verifique**:
   ```bash
   mvn -version
   ```

---

## Método Manual: Instalação Passo a Passo

### Passo 1: Baixar o Maven

1. Acesse: https://maven.apache.org/download.cgi
2. Baixe: **apache-maven-3.9.6-bin.zip** (ou versão mais recente)
3. Salve em uma pasta de fácil acesso (ex: Downloads)

### Passo 2: Extrair o Maven

1. Extraia o arquivo ZIP
2. Mova a pasta extraída para: `C:\Program Files\Apache\maven`
   - O caminho final deve ser: `C:\Program Files\Apache\maven\bin\mvn.cmd`

### Passo 3: Configurar Variáveis de Ambiente

1. **Abra as Variáveis de Ambiente**:
   - Pressione `Win + R`
   - Digite: `sysdm.cpl`
   - Pressione Enter
   - Clique na aba "Avançado"
   - Clique em "Variáveis de Ambiente"

2. **Criar MAVEN_HOME**:
   - Em "Variáveis do sistema", clique em "Novo"
   - Nome: `MAVEN_HOME`
   - Valor: `C:\Program Files\Apache\maven`
   - Clique em "OK"

3. **Adicionar ao PATH**:
   - Encontre a variável `Path` em "Variáveis do sistema"
   - Clique em "Editar"
   - Clique em "Novo"
   - Adicione: `%MAVEN_HOME%\bin`
   - Clique em "OK" em todas as janelas

### Passo 4: Verificar Instalação

1. **Feche TODOS os terminais abertos**
2. **Abra um novo terminal** (PowerShell ou CMD)
3. **Execute**:
   ```bash
   mvn -version
   ```

   Você deve ver algo como:
   ```
   Apache Maven 3.9.6
   Maven home: C:\Program Files\Apache\maven
   Java version: 17.0.x
   ```

### Passo 5: Configurar no Cursor

1. **Instalar Extensão Java**:
   - Pressione `Ctrl+Shift+X`
   - Procure: **"Extension Pack for Java"**
   - Instale

2. **Configurar Maven no Cursor**:
   - Pressione `Ctrl+Shift+P`
   - Digite: `Preferences: Open User Settings (JSON)`
   - Adicione:
   ```json
   {
     "maven.executable.path": "mvn"
   }
   ```

3. **Recarregar Janela**:
   - Pressione `Ctrl+Shift+P`
   - Digite: `Developer: Reload Window`

---

## ✅ Testar no Projeto

1. **Abra o terminal no Cursor** (`Ctrl+`` `)

2. **Navegue até o backend**:
   ```bash
   cd backend
   ```

3. **Compile o projeto**:
   ```bash
   mvn clean install
   ```

   Isso vai:
   - Baixar todas as dependências
   - Compilar o projeto
   - Criar o JAR

4. **Execute o backend**:
   ```bash
   mvn spring-boot:run
   ```

---

## 🚨 Problemas Comuns

### "mvn não é reconhecido"

**Solução**:
- Verifique se o PATH está correto
- Feche e reabra TODOS os terminais
- Reinicie o computador (às vezes necessário)

### "Java não encontrado"

**Solução**:
1. Instale Java 17+ de: https://adoptium.net/
2. Configure `JAVA_HOME`:
   - Variável: `JAVA_HOME`
   - Valor: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`

### Maven não aparece no Cursor

**Solução**:
1. Instale a extensão "Extension Pack for Java"
2. Recarregue a janela do Cursor
3. Abra a pasta `backend` como workspace separado

---

## 📝 Próximos Passos

Após instalar o Maven:

1. ✅ Compilar: `mvn clean install`
2. ✅ Executar: `mvn spring-boot:run`
3. ✅ Testar: `curl http://localhost:8080/api/auth/me`

