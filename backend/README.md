# Sistema Professores API - Backend

API REST desenvolvida em Java com Spring Boot e MongoDB para o Sistema de Gestão Educacional.

## 📋 Pré-requisitos

- Java 17 ou superior
- Maven 3.6+
- MongoDB Atlas (ou MongoDB local)

## 🚀 Como Executar

### 1. Configurar MongoDB

A conexão com MongoDB já está configurada no arquivo `application.properties`:
```
spring.data.mongodb.uri=mongodb+srv://db_arthurTurcka:DbPI4SistemaProfessores@sistemaprofessores.7dz7gfi.mongodb.net/SistemaProfessores?retryWrites=true&w=majority&appName=SistemaProfessores
```

### 2. Compilar e Executar

```bash
# Na pasta backend/
mvn clean install
mvn spring-boot:run
```

A API estará disponível em: `http://localhost:8080/api`

### 3. Testar a API

```bash
# Verificar se está funcionando
curl http://localhost:8080/api/auth/me

# Listar matérias
curl http://localhost:8080/api/courses
```

## 📁 Estrutura do Projeto

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/sistema/
│   │   │   ├── config/          # Configurações (CORS, etc)
│   │   │   ├── controller/      # Controllers REST
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   ├── model/           # Entidades MongoDB
│   │   │   ├── repository/      # Repositórios MongoDB
│   │   │   ├── service/         # Serviços (GridFS, Migration)
│   │   │   └── SistemaProfessoresApplication.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
└── pom.xml
```

## 🔌 Endpoints Disponíveis

### Autenticação
- `GET /api/auth/me` - Informações do usuário autenticado (simulado)

### Cursos/Matérias
- `GET /api/courses` - Lista todas as matérias
- `GET /api/courses/{id}` - Detalhes da matéria
- `GET /api/courses/{id}/students` - Alunos matriculados
- `POST /api/courses/{id}/assignments` - Criar atividade
- `POST /api/courses/{id}/grades` - Lançar nota
- `POST /api/courses/{id}/materials` - Upload material (multipart)
- `DELETE /api/courses/{id}` - Deletar matéria

### Alunos
- `GET /api/students` - Lista todos os alunos
- `POST /api/students` - Criar aluno
- `PUT /api/students/{id}/enrollments` - Atualizar matrículas

### Atividades
- `GET /api/assignments/{id}/submissions` - Lista submissões

### Submissões
- `POST /api/assignments/{assignmentId}/submissions` - Submeter atividade
- `GET /api/submissions/{fileId}/download` - Download do arquivo

### Materiais
- `GET /api/materials/{fileId}/download` - Download do material

### Mensagens
- `GET /api/messages?studentId={id}` - Mensagens do aluno
- `POST /api/messages` - Enviar mensagem

### Migração
- `POST /api/migration/import` - Importar dados do Flutter

## 📦 Armazenamento de Arquivos

Os arquivos são armazenados usando MongoDB GridFS no bucket `files`.

## 🔄 Migração de Dados

Para migrar dados existentes do Flutter:

1. Exporte os dados do SharedPreferences/JSON do Flutter
2. Formate como JSON seguindo a estrutura esperada
3. Faça POST para `/api/migration/import` com o JSON

Estrutura esperada:
```json
{
  "users": [...],
  "subjects": [...],
  "enrollments": {...},
  "courses": {...},
  "materials": [...],
  "submissions": [...],
  "messages": [...]
}
```

## 🛠️ Tecnologias Utilizadas

- Spring Boot 3.2.0
- Spring Data MongoDB
- MongoDB Driver
- Lombok
- Maven

## 📝 Notas

- A autenticação está simulada (retorna usuário mock)
- CORS está configurado para aceitar todas as origens (ajustar em produção)
- Upload máximo de arquivo: 50MB

