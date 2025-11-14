# 📊 Diagrama de Relacionamentos - Sistema de Gestão Educacional

## 🔗 Relacionamentos entre Entidades

```
┌─────────────┐
│    User     │
│─────────────│
│ _id         │
│ name        │
│ ra (unique) │
│ role        │
└──────┬──────┘
       │
       │ 1:N
       │
       ├─────────────────────────────────────┐
       │                                     │
       │                                     │
┌──────▼──────────┐                  ┌──────▼──────────┐
│  Enrollment     │                  │    Message      │
│─────────────────│                  │─────────────────│
│ _id             │                  │ _id             │
│ studentId ──────┘                  │ fromId ─────────┘
│ subjectId ──────┐                  │ toId ───────────┐
└─────────────────┘                  │ content         │
       │                             │ isBroadcast     │
       │ N:1                         └─────────────────┘
       │
┌──────▼──────────┐
│    Subject      │
│─────────────────│
│ _id             │
│ code (unique)   │
│ name            │
│ teacherId?      │
└──────┬──────────┘
       │
       │ 1:N
       │
       ├─────────────────────────────────────┐
       │                                     │
       │                                     │
┌──────▼──────────┐                  ┌──────▼──────────┐
│  Assignment     │                  │    Material     │
│─────────────────│                  │─────────────────│
│ _id             │                  │ _id             │
│ subjectId ──────┘                  │ subjectId ──────┘
│ title           │                  │ title           │
│ description     │                  │ fileName        │
│ dueDate         │                  │ fileUrl         │
│ weight          │                  │ fileStorageId   │
└──────┬──────────┘                  └─────────────────┘
       │
       │ 1:N
       │
       ├─────────────────────────────────────┐
       │                                     │
       │                                     │
┌──────▼──────────┐                  ┌──────▼──────────┐
│  Submission     │                  │     Grade       │
│─────────────────│                  │─────────────────│
│ _id             │                  │ _id             │
│ assignmentId ───┘                  │ assignmentId ───┘
│ studentId ──────┐                  │ studentId ──────┐
│ fileName        │                  │ subjectId       │
│ fileUrl         │                  │ score           │
│ fileStorageId   │                  └─────────────────┘
│ notes           │
│ submittedAt     │
└─────────────────┘
```

## 📋 Descrição dos Relacionamentos

### User (Usuário)
- **Relacionamentos**:
  - 1:N com `Enrollment` (um aluno pode estar matriculado em várias matérias)
  - 1:N com `Message` (pode enviar/receber várias mensagens)
  - 1:N com `Submission` (um aluno pode submeter várias atividades)
  - 1:N com `Grade` (um aluno pode ter várias notas)
  - 1:N com `Subject` (um professor pode lecionar várias matérias - via `teacherId`)

### Subject (Matéria)
- **Relacionamentos**:
  - N:M com `User` via `Enrollment` (muitos alunos em muitas matérias)
  - 1:N com `Assignment` (uma matéria tem várias atividades)
  - 1:N com `Material` (uma matéria tem vários materiais)
  - 1:N com `Grade` (uma matéria tem várias notas)
  - N:1 com `User` (uma matéria tem um professor - opcional)

### Assignment (Atividade)
- **Relacionamentos**:
  - N:1 com `Subject` (uma atividade pertence a uma matéria)
  - 1:N com `Submission` (uma atividade pode ter várias submissões)
  - 1:N com `Grade` (uma atividade pode ter várias notas)

### Submission (Submissão)
- **Relacionamentos**:
  - N:1 com `Assignment` (uma submissão pertence a uma atividade)
  - N:1 com `User` (uma submissão é feita por um aluno)
  - **Regra de Negócio**: Um aluno pode submeter apenas uma vez por atividade (ou permitir reenvio?)

### Grade (Nota)
- **Relacionamentos**:
  - N:1 com `Assignment` (uma nota pertence a uma atividade)
  - N:1 com `User` (uma nota é de um aluno)
  - N:1 com `Subject` (para queries rápidas - denormalização)
  - **Regra de Negócio**: Uma nota por aluno por atividade? Ou permitir múltiplas (reavaliação)?

### Material (Material Didático)
- **Relacionamentos**:
  - N:1 com `Subject` (um material pertence a uma matéria)

### Enrollment (Matrícula)
- **Relacionamentos**:
  - N:1 com `User` (uma matrícula é de um aluno)
  - N:1 com `Subject` (uma matrícula é em uma matéria)
  - **Regra de Negócio**: Índice único composto `{studentId, subjectId}` - um aluno não pode estar matriculado duas vezes na mesma matéria

### Message (Mensagem)
- **Relacionamentos**:
  - N:1 com `User` (fromId - quem enviou)
  - N:1 com `User` (toId - quem recebeu, opcional para broadcast)

## 🔍 Queries Comuns e Índices

### Queries Frequentes

1. **Listar matérias de um aluno**
   ```javascript
   db.enrollments.find({ studentId: ObjectId("...") })
     .populate('subjectId')
   ```

2. **Listar alunos de uma matéria**
   ```javascript
   db.enrollments.find({ subjectId: ObjectId("...") })
     .populate('studentId')
   ```

3. **Listar atividades de uma matéria com submissões**
   ```javascript
   db.assignments.find({ subjectId: ObjectId("...") })
   // Depois buscar submissions para cada assignment
   ```

4. **Listar notas de um aluno em uma matéria**
   ```javascript
   db.grades.find({ 
     studentId: ObjectId("..."), 
     subjectId: ObjectId("...") 
   })
   ```

5. **Calcular média de um aluno em uma matéria**
   ```javascript
   db.grades.aggregate([
     { $match: { studentId: ObjectId("..."), subjectId: ObjectId("...") } },
     { $lookup: { from: "assignments", localField: "assignmentId", foreignField: "_id", as: "assignment" } },
     { $unwind: "$assignment" },
     { $group: {
         _id: "$studentId",
         weightedSum: { $sum: { $multiply: ["$score", "$assignment.weight"] } },
         totalWeight: { $sum: "$assignment.weight" }
       }
     },
     { $project: { average: { $divide: ["$weightedSum", "$totalWeight"] } } }
   ])
   ```

### Índices Essenciais

```javascript
// Users
db.users.createIndex({ ra: 1 }, { unique: true })

// Subjects
db.subjects.createIndex({ code: 1 }, { unique: true })
db.subjects.createIndex({ teacherId: 1 })

// Enrollments
db.enrollments.createIndex({ studentId: 1, subjectId: 1 }, { unique: true })
db.enrollments.createIndex({ subjectId: 1 })

// Assignments
db.assignments.createIndex({ subjectId: 1, createdAt: -1 })
db.assignments.createIndex({ dueDate: 1 })

// Submissions
db.submissions.createIndex({ assignmentId: 1, studentId: 1 })
db.submissions.createIndex({ studentId: 1, submittedAt: -1 })

// Grades
db.grades.createIndex({ assignmentId: 1, studentId: 1 }, { unique: true })
db.grades.createIndex({ subjectId: 1, studentId: 1 })
db.grades.createIndex({ studentId: 1 })

// Materials
db.materials.createIndex({ subjectId: 1, uploadedAt: -1 })

// Messages
db.messages.createIndex({ toId: 1, sentAt: -1 })
db.messages.createIndex({ fromId: 1, sentAt: -1 })
db.messages.createIndex({ isBroadcast: 1, sentAt: -1 })
```

## 🎯 Considerações de Design

### Denormalização
- `Grade.subjectId`: Armazenado para evitar joins desnecessários ao buscar notas por matéria
- `Submission.studentName`: Pode ser denormalizado para evitar lookup, mas melhor buscar do User quando necessário

### Soft Delete
Considerar adicionar campo `deletedAt` em todas as coleções para permitir recuperação:
```javascript
{
  // ... campos existentes
  deletedAt: Date?,
  isDeleted: Boolean (default: false)
}
```

### Versionamento
Para auditoria, considerar adicionar:
```javascript
{
  // ... campos existentes
  createdAt: Date,
  updatedAt: Date,
  createdBy: ObjectId?,
  updatedBy: ObjectId?
}
```

