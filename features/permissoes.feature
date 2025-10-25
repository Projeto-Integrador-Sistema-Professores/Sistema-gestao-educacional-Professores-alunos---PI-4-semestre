# language: pt
Funcionalidade: Controle de permissões e autorização
  Como administrador
  Quero garantir que as permissões de acesso sejam respeitadas
  Para que apenas usuários autorizados realizem ações específicas

  Contexto:
    Dado que existe um professor com RA "RAPROF1" e papel "professor"
      E existe um aluno com RA "RAALUNO1" e papel "aluno"

  @security @api
  Cenário: PM-01 - Professor pode criar turma e lançar notas
    Dado que estou autenticado como RA "RAPROF1" com papel "professor"
    Quando eu enviar uma requisição para criar uma turma ou lançar notas
    Então a API deve retornar 201 Created ou 200 OK
      E a ação deve ser persistida no banco

  @security @negative
  Cenário: PM-02 - Aluno não pode editar dados de outro aluno
    Dado que estou autenticado como RA "RAALUNO1" com papel "aluno"
    Quando eu tentar atualizar a nota ou perfil de outro aluno
    Então a API deve retornar 403 Forbidden
      E a interface deve exibir "Ação não autorizada"

  @security @negative @api
  Cenário: PM-03 - Usuário não autenticado não acessa rotas protegidas
    Dado que não estou autenticado
    Quando eu solicitar endpoints protegidos como /turmas ou /grades
    Então a API deve retornar 401 Unauthorized
      E o frontend deve redirecionar para a tela de login

  @regression @security
  Cenário: PM-04 - Verificação dupla: frontend e backend
    Dado que o frontend envia uma requisição alegando papel "professor" sem um JWT válido
    Quando o backend receber a requisição
    Então o backend deve validar o JWT e o papel server-side e retornar 401/403 se inválido
