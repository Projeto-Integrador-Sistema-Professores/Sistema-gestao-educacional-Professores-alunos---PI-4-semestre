# language: pt
Funcionalidade: Recuperação de senha
  Como usuário cadastrado
  Quero recuperar minha senha esquecida
  Para poder acessar o sistema novamente

  Contexto:
    Dado que existe um usuário cadastrado com RA "RA123456" e email "usuario@exemplo.com"

  @smoke @ui
  Cenário: RP-01 - Exibir opção "Esqueci minha senha" na tela de login
    Dado que estou na tela de login
    Então devo ver um link ou botão rotulado "Esqueci minha senha"

  @regression @api @email
  Cenário: RP-02 - Solicitação de redefinição por RA envia e-mail com token
    Dado que estou na tela de login
    Quando eu clicar em "Esqueci minha senha"
      E eu informar o RA "RA123456" e submeter a solicitação
    Então o sistema deve responder com 200 OK
      E um e-mail contendo um token ou link de redefinição deve ser enviado para "usuario@exemplo.com"
      E o token deve ser armazenado (hashed) no servidor com metadados de expiração

  @security @negative @api
  Cenário: RP-03 - Solicitação com RA inexistente não vaza existência de conta
    Dado que estou na tela de login
    Quando eu informar o RA "RA000000" e solicitar redefinição de senha
    Então o sistema deve retornar uma mensagem genérica de sucesso (ex.: "Se houver uma conta, enviamos instruções")
      E não deve revelar se a conta existe

  @regression @api
  Cenário: RP-04 - Token expira após tempo configurável (ex.: 60 minutos)
    Dado que um token de redefinição foi emitido para RA "RA123456" no tempo T0
    Quando o tempo atual for maior que T0 + 60 minutos
    Então o token deve ser inválido para redefinição de senha (servidor retorna 400/401)

  @regression @e2e
  Cenário: RP-05 - Redefinição substitui a senha antiga
    Dado que recebi um token válido de redefinição por e-mail
    Quando eu usar o token para definir a senha para "NovaSenha!23"
    Então o login com a senha antiga "SenhaAntiga" deve falhar
      E o login com "NovaSenha!23" deve suceder
