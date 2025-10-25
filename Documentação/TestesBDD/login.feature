# language: pt
Funcionalidade: Autenticação com RA e senha
  Como usuário (professor ou aluno)
  Quero autenticar usando meu RA e senha
  Para consultar e gerenciar minhas informações acadêmicas

  Contexto:
    Dado que existe um usuário com RA "RA200300" e senha "Senha123!"

  @smoke @ui
  Cenário: LG-01 - Login com credenciais válidas
    Dado que estou na tela de login
    Quando eu informar o RA "RA200300" e a senha "Senha123!"
      E pressionar o botão de login
    Então devo ser redirecionado para o dashboard
      E um token de sessão (JWT) deve ser armazenado de forma segura (ex.: secure storage)

  @negative @ui
  Cenário: LG-02 - Senha inválida retorna mensagem clara
    Dado que estou na tela de login
    Quando eu informar o RA "RA200300" e a senha "SenhaErrada"
      E pressionar o botão de login
    Então devo ver a mensagem de erro "RA ou senha inválidos"

  @regression @security
  Cenário: LG-03 - Logout encerra sessão e impede acesso a rotas protegidas
    Dado que estou autenticado como RA "RA200300"
    Quando eu pressionar logout
    Então devo ser redirecionado para a tela de login
      E o acesso a rotas protegidas (ex.: /grades) deve redirecionar para login ou retornar 401

  @security @api
  Cenário: LG-04 - Token expirado impede acesso e exige novo login
    Dado que possuo um token JWT expirado
    Quando eu chamar um endpoint protegido utilizando esse token
    Então a API deve retornar HTTP 401 Unauthorized
