# ⚡ Quick Start - Instalar Maven (Método Mais Rápido)

## 🚀 Opção 1: Instalação Automática (Recomendado)

### Windows com Chocolatey:

1. **Abra PowerShell como Administrador**
   - Clique com botão direito no PowerShell
   - Selecione "Executar como administrador"

2. **Instale o Chocolatey** (se não tiver):
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

3. **Instale o Maven**:
   ```powershell
   choco install maven -y
   ```

4. **Feche e reabra o terminal**

5. **Verifique**:
   ```bash
   mvn -version
   ```

✅ **Pronto!** Maven instalado.

---

## 📦 Opção 2: Usar o Script Fornecido

1. **Abra PowerShell como Administrador**

2. **Execute o script**:
   ```powershell
   cd "E:\Arthur Trindade\Maua\Sistema-gestao-educacional-Professores-alunos---PI-4-semestre-1"
   .\INSTALAR_MAVEN_WINDOWS.ps1
   ```

3. **Feche e reabra o terminal**

---

## ⚙️ Configurar no Cursor

### 1. Instalar Extensão Java

1. Pressione `Ctrl+Shift+X`
2. Procure: **"Extension Pack for Java"** (Microsoft)
3. Clique em **Install**

### 2. Recarregar Janela

1. Pressione `Ctrl+Shift+P`
2. Digite: `Developer: Reload Window`
3. Pressione Enter

### 3. Abrir Pasta do Backend

1. Pressione `Ctrl+K` depois `Ctrl+O`
2. Navegue até: `backend`
3. Abra a pasta

O Cursor deve detectar o projeto Maven automaticamente!

---

## ✅ Testar

No terminal do Cursor:

```bash
cd backend
mvn clean install
```

Se funcionar, você verá o Maven baixando dependências e compilando.

---

## 🎯 Próximo Passo

Depois de instalar o Maven:

```bash
cd backend
mvn spring-boot:run
```

Isso vai iniciar o backend na porta 8080!

---

## 📚 Documentação Completa

Para mais detalhes, veja:
- `CONFIGURAR_MAVEN.md` - Guia completo
- `INSTALAR_MAVEN_MANUAL.md` - Instalação manual passo a passo

