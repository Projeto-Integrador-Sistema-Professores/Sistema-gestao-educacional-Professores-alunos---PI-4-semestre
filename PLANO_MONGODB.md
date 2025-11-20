# 📊 Análise Profunda da API e Plano de Integração com MongoDB

## 🔍 Análise da Estrutura Atual

### Tecnologias Utilizadas
- **Frontend**: Flutter (Dart)
- **Armazenamento Atual**: 
  - `SharedPreferences` (dados estruturados)
  - Arquivos JSON locais (assignments e grades)
- **API**: Simulação local (`useFakeApi = true`)
- **HTTP Client**: Dio
- **Estado**: Riverpod

### Modelos de Dados Identificados

#### 1. **User (Usuários)**
```dart
- id: String
- name: String
- ra: String (Registro Acadêmico)
- role: String ("student" | "teacher")
```

#### 2. **Subject/Course (Matérias)**
```dart
- id: String
- name: String
- code: String (ex: "MAT101", "PROG202")
- description: String? (opcional)
```

#### 3. **Assignment (Atividades)**
```dart
- id: String
- courseId: String (referência à matéria)
- title: String
- description: String
- dueDate: DateTime
- weight: double
- createdAt: DateTime
```

#### 4. **Submission (Submissões de Atividades)**
```dart
- id: String
- assignmentId: String
- studentId: String
- studentName: String?
- fileName: String?
- fileUrl: String? (URL ou path do arquivo)
- fileData: String? (Base64 para web)
- notes: String?
- submittedAt: DateTime
```

#### 5. **Grade (Notas)**
```dart
- id: String? (gerado no backend)
- studentId: String
- studentName: String?
- assignmentId: String
- courseId: String (implícito via assignment)
- score: double
- finalGrade: double? (calculado)
- createdAt: DateTime
```

#### 6. **MaterialItem (Materiais Didáticos)**
```dart
- id: String
- courseId: String
- title: String
- fileName: String?
- fileUrl: String
- fileData: String? (Base64)
```

#### 7. **Message (Mensagens)**
```dart
- id: String
- fromId: String (professor ID)
- toId: String? (aluno ID, null = broadcast)
- toName: String?
- content: String
- sentAt: DateTime
- isBroadcast: boolean
```

#### 8. **Enrollment (Matrículas)**
```dart
- studentId: String
- subjectIds: List<String> (matérias em que o aluno está matriculado)
```

### Endpoints Atuais (Fake API)

#### GET
- `GET /courses` - Lista todas as matérias
- `GET /courses/{id}` - Detalhes da matéria (com materials, assignments, grades)
- `GET /courses/{id}/students` - Alunos matriculados na matéria
- `GET /students` - Lista todos os alunos (com matérias matriculadas)
- `GET /messages?studentId={id}` - Mensagens para um aluno
- `GET /assignments/{id}/submissions` - Submissões de uma atividade
- `GET /auth/me` - Informações do usuário autenticado

#### POST
- `POST /courses/{id}/assignments` - Criar atividade
- `POST /courses/{id}/grades` - Lançar nota
- `POST /courses/{id}/materials` - Adicionar material
- `POST /students` - Criar aluno
- `POST /messages` - Enviar mensagem
- `POST /assignments/{id}/submissions` - Submeter atividade

#### PUT
- `PUT /students/{id}/enrollments` - Atualizar matrículas do aluno

#### DELETE
- `DELETE /courses/{id}` - Deletar matéria

---

## 🎯 Plano de Integração com MongoDB

### Fase 1: Preparação e Configuração do Backend

#### 1.1 Escolha da Stack Backend
**Recomendação**: Node.js + Express + MongoDB (Mongoose)

**Alternativas**:
- Python + FastAPI + Motor/PyMongo
- NestJS + TypeScript + Mongoose
- Go + Gin + mongo-go-driver

#### 1.2 Estrutura de Coleções MongoDB

```javascript
// 1. users (Usuários - Alunos e Professores)
{
  _id: ObjectId,
  name: String,
  ra: String (único, indexado),
  role: "student" | "teacher",
  email: String? (opcional, para autenticação futura),
  passwordHash: String? (se implementar auth),
  createdAt: Date,
  updatedAt: Date
}

// 2. subjects (Matérias/Cursos)
{
  _id: ObjectId,
  code: String (único, indexado),
  name: String,
  description: String?,
  teacherId: ObjectId? (referência ao professor),
  createdAt: Date,
  updatedAt: Date
}

// 3. enrollments (Matrículas - Relação Aluno-Matéria)
{
  _id: ObjectId,
  studentId: ObjectId (referência a users),
  subjectId: ObjectId (referência a subjects),
  enrolledAt: Date,
  // Índice composto: {studentId: 1, subjectId: 1}
}

// 4. assignments (Atividades)
{
  _id: ObjectId,
  subjectId: ObjectId (referência a subjects),
  title: String,
  description: String,
  dueDate: Date,
  weight: Number (double),
  createdAt: Date,
  updatedAt: Date
}

// 5. submissions (Submissões)
{
  _id: ObjectId,
  assignmentId: ObjectId (referência a assignments),
  studentId: ObjectId (referência a users),
  fileName: String?,
  fileUrl: String? (URL do arquivo no storage),
  fileStorageId: String? (ID no GridFS ou S3),
  notes: String?,
  submittedAt: Date,
  updatedAt: Date
}

// 6. grades (Notas)
{
  _id: ObjectId,
  studentId: ObjectId (referência a users),
  assignmentId: ObjectId (referência a assignments),
  subjectId: ObjectId (referência a subjects, para queries rápidas),
  score: Number (double),
  createdAt: Date,
  updatedAt: Date
}

// 7. materials (Materiais Didáticos)
{
  _id: ObjectId,
  subjectId: ObjectId (referência a subjects),
  title: String,
  fileName: String?,
  fileUrl: String?,
  fileStorageId: String? (ID no GridFS ou S3),
  uploadedAt: Date,
  updatedAt: Date
}

// 8. messages (Mensagens)
{
  _id: ObjectId,
  fromId: ObjectId (referência a users - professor),
  toId: ObjectId? (referência a users - aluno, null = broadcast),
  content: String,
  isBroadcast: Boolean,
  sentAt: Date
}
```

#### 1.3 Armazenamento de Arquivos

**Opções**:
1. **MongoDB GridFS** (recomendado para começar)
   - Integrado ao MongoDB
   - Suporta arquivos grandes
   - Fácil de implementar

2. **AWS S3 / Google Cloud Storage** (produção)
   - Escalável
   - CDN integrado
   - Custo por uso

3. **Local Storage** (desenvolvimento)
   - Simples para testes
   - Não recomendado para produção

**Recomendação**: Começar com GridFS, migrar para S3/GCS depois.

---

### Fase 2: Desenvolvimento do Backend API

#### 2.1 Estrutura de Pastas do Backend

```
backend/
├── src/
│   ├── models/
│   │   ├── User.js
│   │   ├── Subject.js
│   │   ├── Enrollment.js
│   │   ├── Assignment.js
│   │   ├── Submission.js
│   │   ├── Grade.js
│   │   ├── Material.js
│   │   └── Message.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── courses.js
│   │   ├── students.js
│   │   ├── assignments.js
│   │   ├── submissions.js
│   │   ├── grades.js
│   │   ├── materials.js
│   │   └── messages.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── courseController.js
│   │   ├── studentController.js
│   │   ├── assignmentController.js
│   │   ├── submissionController.js
│   │   ├── gradeController.js
│   │   ├── materialController.js
│   │   └── messageController.js
│   ├── middleware/
│   │   ├── auth.js
│   │   └── errorHandler.js
│   ├── config/
│   │   ├── database.js
│   │   └── storage.js
│   ├── utils/
│   │   ├── fileUpload.js
│   │   └── validators.js
│   └── app.js
├── package.json
└── .env
```

#### 2.2 Endpoints da API REST

**Autenticação**
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Registro (opcional)
- `GET /api/auth/me` - Informações do usuário autenticado

**Cursos/Matérias**
- `GET /api/courses` - Lista matérias
- `GET /api/courses/:id` - Detalhes da matéria
- `POST /api/courses` - Criar matéria
- `PUT /api/courses/:id` - Atualizar matéria
- `DELETE /api/courses/:id` - Deletar matéria
- `GET /api/courses/:id/students` - Alunos matriculados

**Alunos**
- `GET /api/students` - Lista alunos
- `GET /api/students/:id` - Detalhes do aluno
- `POST /api/students` - Criar aluno
- `PUT /api/students/:id` - Atualizar aluno
- `DELETE /api/students/:id` - Deletar aluno
- `PUT /api/students/:id/enrollments` - Atualizar matrículas

**Atividades**
- `GET /api/courses/:id/assignments` - Lista atividades da matéria
- `POST /api/courses/:id/assignments` - Criar atividade
- `PUT /api/assignments/:id` - Atualizar atividade
- `DELETE /api/assignments/:id` - Deletar atividade

**Submissões**
- `GET /api/assignments/:id/submissions` - Lista submissões
- `GET /api/submissions/:id` - Detalhes da submissão
- `POST /api/assignments/:id/submissions` - Submeter atividade (multipart/form-data)
- `GET /api/submissions/:id/download` - Download do arquivo

**Notas**
- `GET /api/courses/:id/grades` - Lista notas da matéria
- `GET /api/assignments/:id/grades` - Lista notas da atividade
- `POST /api/courses/:id/grades` - Lançar nota
- `PUT /api/grades/:id` - Atualizar nota
- `DELETE /api/grades/:id` - Deletar nota

**Materiais**
- `GET /api/courses/:id/materials` - Lista materiais
- `POST /api/courses/:id/materials` - Upload material (multipart/form-data)
- `DELETE /api/materials/:id` - Deletar material
- `GET /api/materials/:id/download` - Download do material

**Mensagens**
- `GET /api/messages?studentId=:id` - Mensagens do aluno
- `POST /api/messages` - Enviar mensagem

---

### Fase 3: Migração do Frontend Flutter

#### 3.1 Alterações Necessárias

1. **Atualizar `constants.dart`**
   ```dart
   const bool useFakeApi = false; // Mudar para false
   const String apiBaseUrl = 'https://seu-backend.com/api'; // URL real
   ```

2. **Manter compatibilidade com modelos existentes**
   - Os modelos já estão bem estruturados
   - Apenas ajustar `fromJson` se necessário

3. **Adicionar tratamento de erros**
   - Interceptadores no Dio
   - Mensagens de erro amigáveis

4. **Upload de arquivos**
   - Usar `FormData` do Dio para multipart
   - Progress callbacks para feedback visual

#### 3.2 Autenticação
- Implementar JWT token storage
- Adicionar refresh token se necessário
- Interceptor para adicionar token nas requisições

---

### Fase 4: Migração de Dados

#### 4.1 Script de Migração

Criar script Node.js para:
1. Ler dados do SharedPreferences (exportar JSON)
2. Ler arquivos JSON locais
3. Transformar para formato MongoDB
4. Inserir no banco

#### 4.2 Estratégia
- **Desenvolvimento**: Migração completa
- **Produção**: Migração incremental ou paralela

---

## 📋 Informações Necessárias do Usuário

Para implementar a integração, preciso das seguintes informações:

### 1. **Configuração do MongoDB**
- [ ] String de conexão MongoDB (MongoDB Atlas ou local)
- [ ] Nome do banco de dados
- [ ] Credenciais (usuário e senha)
- [ ] Se está usando MongoDB Atlas, fornecer a connection string completa

### 2. **Stack Backend**
- [ ] Preferência de linguagem (Node.js, Python, Go, etc.)
- [ ] Se já existe um backend, fornecer detalhes
- [ ] Se precisa criar do zero

### 3. **Autenticação**
- [ ] Se deseja implementar autenticação JWT agora
- [ ] Ou manter apenas simulação de auth por enquanto

### 4. **Armazenamento de Arquivos**
- [ ] Preferência: GridFS, S3, ou outro
- [ ] Se S3/GCS: credenciais e configurações

### 5. **Deploy**
- [ ] Onde vai hospedar o backend (Heroku, AWS, Vercel, etc.)
- [ ] Domínio/URL da API

### 6. **Dados Existentes**
- [ ] Se deseja migrar dados existentes do SharedPreferences
- [ ] Ou começar com banco vazio

---

## 🚀 Próximos Passos

1. **Fornecer as informações acima**
2. **Criar estrutura do backend** (se necessário)
3. **Configurar conexão MongoDB**
4. **Criar modelos Mongoose/Schema**
5. **Implementar endpoints REST**
6. **Configurar upload de arquivos**
7. **Atualizar frontend Flutter**
8. **Testar integração completa**
9. **Migrar dados existentes** (se aplicável)

---

## 📝 Notas Importantes

### Índices MongoDB Recomendados
```javascript
// users
db.users.createIndex({ ra: 1 }, { unique: true })

// subjects
db.subjects.createIndex({ code: 1 }, { unique: true })

// enrollments
db.enrollments.createIndex({ studentId: 1, subjectId: 1 }, { unique: true })

// assignments
db.assignments.createIndex({ subjectId: 1, createdAt: -1 })

// submissions
db.submissions.createIndex({ assignmentId: 1, studentId: 1 })
db.submissions.createIndex({ studentId: 1, submittedAt: -1 })

// grades
db.grades.createIndex({ assignmentId: 1, studentId: 1 }, { unique: true })
db.grades.createIndex({ subjectId: 1, studentId: 1 })

// materials
db.materials.createIndex({ subjectId: 1, uploadedAt: -1 })

// messages
db.messages.createIndex({ toId: 1, sentAt: -1 })
db.messages.createIndex({ fromId: 1, sentAt: -1 })
```

### Validações Importantes
- RA único por usuário
- Código de matéria único
- Um aluno não pode estar matriculado duas vezes na mesma matéria
- Uma nota por aluno por atividade (ou permitir múltiplas?)
- Validação de datas (dueDate não pode ser no passado ao criar?)

### Segurança
- Validação de entrada em todos os endpoints
- Sanitização de dados
- Rate limiting
- CORS configurado corretamente
- Autenticação/autorização (professor vs aluno)

---

## ❓ Perguntas para Decisão

1. **Notas**: Um aluno pode ter múltiplas notas na mesma atividade? (ex: reavaliação)
2. **Arquivos**: Tamanho máximo permitido?
3. **Matrículas**: Alunos podem se auto-inscrever ou apenas professores?
4. **Mensagens**: Histórico ilimitado ou com limite de tempo?
5. **Soft Delete**: Deletar permanentemente ou marcar como deletado?

---

**Aguardando suas respostas para iniciar a implementação! 🎯**

