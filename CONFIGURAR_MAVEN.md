# 🔧 Como Configurar Maven no Cursor/VS Code

## 📋 Passo 1: Verificar se o Maven está Instalado

Abra o terminal (PowerShell ou CMD) e execute:

```bash
mvn -version
```

Se aparecer algo como:
```
Apache Maven 3.x.x
Maven home: C:\Program Files\Apache\maven
Java version: 17.x.x
```

✅ **Maven está instalado!** Pule para o Passo 3.

Se aparecer "mvn não é reconhecido como comando":
❌ **Maven NÃO está instalado.** Continue para o Passo 2.

---

## 📥 Passo 2: Instalar o Maven (se necessário)

### Opção A: Instalar via Chocolatey (Recomendado - Windows)

1. **Instalar Chocolatey** (se não tiver):
   - Abra PowerShell como **Administrador**
   - Execute:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. **Instalar Maven**:
   ```powershell
   choco install maven
   ```

3. **Reinicie o terminal** e verifique:
   ```bash
   mvn -version
   ```

### Opção B: Instalação Manual

1. **Baixar Maven**:
   - Acesse: https://maven.apache.org/download.cgi
   - Baixe o arquivo `apache-maven-3.9.x-bin.zip`

2. **Extrair**:
   - Extraia para `C:\Program Files\Apache\maven` (ou outro local)

3. **Configurar Variáveis de Ambiente**:
   - Abra "Variáveis de Ambiente" do Windows
   - Adicione `MAVEN_HOME` = `C:\Program Files\Apache\maven`
   - Adicione ao `PATH`: `%MAVEN_HOME%\bin`

4. **Verificar**:
   - Abra um novo terminal
   - Execute: `mvn -version`

---

## ⚙️ Passo 3: Configurar Maven no Cursor/VS Code

### 1. Instalar Extensão Java

No Cursor/VS Code:

1. Pressione `Ctrl+Shift+X` para abrir Extensions
2. Procure por: **"Extension Pack for Java"** (Microsoft)
3. Clique em **Install**

Isso instala:
- Language Support for Java
- Debugger for Java
- Test Runner for Java
- Maven for Java
- Project Manager for Java

### 2. Configurar o Maven no Cursor

1. Pressione `Ctrl+Shift+P` (ou `F1`)
2. Digite: **"Java: Configure Java Runtime"**
3. Selecione a opção
4. Configure o caminho do Maven se necessário

### 3. Configurar Settings.json

1. Pressione `Ctrl+Shift+P`
2. Digite: **"Preferences: Open User Settings (JSON)"**
3. Adicione as seguintes configurações:

```json
{
  "java.configuration.maven.userSettings": null,
  "java.configuration.maven.globalSettings": null,
  "maven.executable.path": "mvn",
  "maven.terminal.useJavaHome": true,
  "java.home": null
}
```

**Se o Maven estiver em um caminho específico**, use:
```json
{
  "maven.executable.path": "C:\\Program Files\\Apache\\maven\\bin\\mvn.cmd"
}
```

### 4. Recarregar a Janela

1. Pressione `Ctrl+Shift+P`
2. Digite: **"Developer: Reload Window"**
3. Pressione Enter

---

## 🔍 Passo 4: Verificar Configuração

### No Terminal do Cursor:

1. Abra o terminal integrado (`Ctrl+`` ` ou Terminal > New Terminal)
2. Navegue até a pasta do backend:
   ```bash
   cd backend
   ```
3. Execute:
   ```bash
   mvn -version
   ```
4. Execute:
   ```bash
   mvn clean install
   ```

Se tudo funcionar, você verá o Maven baixando dependências e compilando o projeto.

---

## 🚨 Troubleshooting

### Erro: "Maven executable not found"

**Solução 1**: Verificar PATH
```bash
# No PowerShell
$env:PATH -split ';' | Select-String -Pattern 'maven'
```

Se não aparecer, adicione o Maven ao PATH (veja Passo 2).

**Solução 2**: Especificar caminho manualmente
No `settings.json` do Cursor:
```json
{
  "maven.executable.path": "C:\\caminho\\completo\\para\\mvn.cmd"
}
```

### Erro: "Java not found"

1. Verifique se o Java 17+ está instalado:
   ```bash
   java -version
   ```

2. Se não estiver, instale:
   - Baixe: https://adoptium.net/
   - Instale Java 17 LTS

3. Configure `JAVA_HOME`:
   - Variável: `JAVA_HOME`
   - Valor: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot` (ou seu caminho)

### Erro: "Failed to calculate Effective POM"

**Solução**:
1. Feche o Cursor
2. Delete a pasta `.vscode` no projeto (se existir)
3. Abra o Cursor novamente
4. Abra a pasta `backend` como workspace
5. Aguarde o Maven baixar as dependências

### Maven não aparece no Cursor

1. Verifique se a extensão "Maven for Java" está instalada
2. Pressione `Ctrl+Shift+P`
3. Digite: **"Java: Clean Java Language Server Workspace"**
4. Recarregue a janela

---

## ✅ Verificação Final

Após configurar tudo, você deve conseguir:

1. ✅ Ver o Maven no terminal: `mvn -version`
2. ✅ Compilar o projeto: `mvn clean install`
3. ✅ Ver o projeto Java no Cursor com syntax highlighting
4. ✅ Ver a estrutura Maven no explorador (pom.xml)

---

## 🎯 Próximos Passos

Depois de configurar o Maven:

1. **Compilar o projeto**:
   ```bash
   cd backend
   mvn clean install
   ```

2. **Executar o backend**:
   ```bash
   mvn spring-boot:run
   ```

3. **Testar**:
   ```bash
   curl http://localhost:8080/api/auth/me
   ```

---

## 📝 Notas Importantes

- O Cursor usa as mesmas extensões do VS Code
- Certifique-se de ter Java 17+ instalado
- O Maven precisa estar no PATH do sistema
- Reinicie o Cursor após instalar o Maven

