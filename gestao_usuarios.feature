# language: pt
Funcionalidade: Gestão de usuários (cadastro e edição)
  Como administrador ou professor responsável
  Quero cadastrar e editar perfis de usuários
  Para que professores e alunos possam acessar o sistema corretamente

  Contexto:
    Dado que estou autenticado como administrador

  @regression @api
  Cenário: UM-01 - Criar usuário com RA único
    Dado que não existe usuário com RA "RA300400"
    Quando eu criar um usuário com RA "RA300400", nome "Fulano Silva", email "fulano@uni.edu" e papel "aluno"
    Então a API deve retornar 201 Created
      E a interface deve mostrar "Usuário cadastrado com sucesso"
      E o registro do usuário deve existir no banco com papel "aluno"

  @negative @api
  Cenário: UM-02 - Não permitir RA duplicado
    Dado que já existe um usuário com RA "RA300400"
    Quando eu tentar criar outro usuário com RA "RA300400"
    Então a API deve retornar 409 Conflict
      E a interface deve exibir "RA já existe"

  @regression @ui
  Cenário: UM-03 - Edição permite alterar nome e email, não o RA
    Dado que existe um usuário com RA "RA300400", nome "Fulano Silva" e email "fulano@uni.edu"
    Quando eu editar o usuário alterando o nome para "Fulano S." e email para "fulano.s@uni.edu"
    Então a API deve atualizar nome e email
      E o RA deve permanecer "RA300400"
      E a interface deve mostrar "Dados atualizados com sucesso"

  @validation @negative
  Cenário: UM-04 - Campos obrigatórios são validados
    Dado que estou no formulário de criação de usuário
    Quando eu submeter o formulário com RA vazio ou nome vazio ou email inválido "nao-email"
    Então a interface deve mostrar erros de validação para os campos obrigatórios e email inválido
