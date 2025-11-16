# 🚀 Instruções de Execução - Backend

## Passo a Passo para Executar o Backend

### 1. Verificar Pré-requisitos

Certifique-se de ter instalado:
- **Java 17+**: `java -version`
- **Maven 3.6+**: `mvn -version`

### 2. Navegar para a Pasta do Backend

```bash
cd backend
```

### 3. Compilar o Projeto

```bash
mvn clean install
```

### 4. Executar a Aplicação

```bash
mvn spring-boot:run
```

Ou se preferir compilar um JAR:

```bash
mvn clean package
java -jar target/sistema-professores-api-1.0.0.jar
```

### 5. Verificar se Está Funcionando

Abra o navegador ou use curl:

```bash
# Testar endpoint de autenticação
curl http://localhost:8080/api/auth/me

# Deve retornar:
# {"id":"u1","name":"Prof. João","ra":"123456","role":"teacher"}
```

### 6. Configurar Frontend Flutter

No arquivo `lib/src/utils/constants.dart`, certifique-se de que:

```dart
const bool useFakeApi = false;
const String apiBaseUrl = 'http://localhost:8080/api';
```

**Nota**: Se estiver testando em dispositivo físico ou emulador Android, use:
- Android Emulator: `http://10.0.2.2:8080/api`
- iOS Simulator: `http://localhost:8080/api`
- Dispositivo físico: Use o IP da sua máquina, ex: `http://192.168.1.100:8080/api`

### 7. Migrar Dados Existentes (Opcional)

Se você tem dados no Flutter que deseja migrar:

1. Exporte os dados (veja `MIGRACAO_DADOS.md`)
2. Envie para o endpoint de migração:

```bash
curl -X POST http://localhost:8080/api/migration/import \
  -H "Content-Type: application/json" \
  -d @export_data.json
```

## 🔧 Troubleshooting

### Erro: "Port 8080 already in use"

Altere a porta no `application.properties`:
```properties
server.port=8081
```

E atualize o `apiBaseUrl` no Flutter.

### Erro: "Cannot connect to MongoDB"

Verifique:
1. A connection string no `application.properties`
2. Se o MongoDB Atlas está acessível
3. Se o IP está na whitelist do MongoDB Atlas

### Erro: "ClassNotFoundException"

Execute:
```bash
mvn clean install
mvn spring-boot:run
```

### Frontend não consegue conectar

1. Verifique se o backend está rodando
2. Verifique a URL no `constants.dart`
3. Para Android/iOS, use o IP correto (não localhost)
4. Verifique CORS (já configurado para aceitar todas as origens)

## 📝 Próximos Passos

1. ✅ Backend rodando
2. ✅ Frontend configurado
3. ⬜ Migrar dados (se necessário)
4. ⬜ Testar todas as funcionalidades
5. ⬜ Deploy (quando estiver pronto)

## 🎯 Testando Endpoints

### Criar uma Matéria
```bash
curl -X POST http://localhost:8080/api/courses \
  -H "Content-Type: application/json" \
  -d '{"code":"MAT101","name":"Cálculo I","description":"..."}'
```

### Listar Alunos
```bash
curl http://localhost:8080/api/students
```

### Criar Aluno
```bash
curl -X POST http://localhost:8080/api/students \
  -H "Content-Type: application/json" \
  -d '{"name":"João Silva","ra":"2024001","role":"student"}'
```

