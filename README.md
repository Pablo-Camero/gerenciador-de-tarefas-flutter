:::writing{variant="document" id="58321"}
# Gerenciador de Tarefas — Flutter e Firebase

## Descrição

Aplicativo de gerenciamento de tarefas desenvolvido em Flutter e Dart, com autenticação de usuários e armazenamento de dados utilizando Firebase.

O projeto permite que cada usuário organize suas tarefas, acompanhe atividades pendentes e concluídas e personalize a aparência do aplicativo.

## Tecnologias utilizadas

- Flutter e Dart
- Firebase Authentication
- Firebase Realtime Database
- SharedPreferences
- Material Design 3

## Funcionalidades

- Cadastro de usuários com nome, e-mail e senha.
- Login e logout.
- Identificação do usuário no menu lateral.
- Cadastro de tarefas com título, descrição, vencimento e prioridade.
- Listagem de tarefas em tempo real.
- Edição e exclusão de tarefas.
- Marcação de tarefas como concluídas.
- Resumo de tarefas na tela inicial.
- Tema claro e escuro.
- Armazenamento local da preferência de tema.
- Exclusão de conta e dos dados associados.

## Pré-requisitos

Para executar o projeto, é necessário ter:

- Flutter SDK instalado.
- Dart SDK (incluído no Flutter).
- Android SDK e um dispositivo ou emulador Android.
- Projeto Firebase configurado.
- Firebase CLI e FlutterFire CLI, caso seja necessário gerar novamente a configuração do Firebase.

## Configuração do Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
2. Ative o Firebase Authentication com o provedor E-mail/Senha.
3. Crie um Firebase Realtime Database.
4. Configure as regras de segurança para que cada usuário acesse somente seus próprios dados.
5. Configure o aplicativo Android no Firebase.
6. Instale e utilize o FlutterFire CLI para gerar o arquivo `lib/firebase_options.dart`:

```bash
flutterfire configure
```

7. Verifique se o arquivo `main.dart` inicializa o Firebase com `Firebase.initializeApp()` e `DefaultFirebaseOptions.currentPlatform`.

### Estrutura dos dados

Os dados são organizados no Realtime Database por UID:

```text
usuarios/
  UID_DO_USUARIO/
    nome
    email

tarefas/
  UID_DO_USUARIO/
    ID_DA_TAREFA/
      titulo
      descricao
      dataVencimento
      prioridade
      concluida
```

### Regras de segurança

Configure regras de acesso que permitam a leitura e a escrita somente pelo usuário autenticado correspondente ao UID.

Não utilize regras públicas de leitura e escrita em um banco de dados de produção.

## Como executar

Clone o repositório:

```bash
git clone URL_DO_REPOSITORIO
```

Entre na pasta do projeto:

```bash
cd gerenciador_p2
```

Instale as dependências:

```bash
flutter pub get
```

Verifique os dispositivos disponíveis:

```bash
flutter devices
```

Execute o aplicativo:

```bash
flutter run
```

Caso o projeto esteja sendo configurado com um Firebase diferente, execute `flutterfire configure` antes de iniciar o aplicativo.

## Testes

Para testar o aplicativo:

1. Cadastre uma conta.
2. Faça login.
3. Cadastre uma tarefa.
4. Edite os dados da tarefa.
5. Marque a tarefa como concluída.
6. Exclua uma tarefa.
7. Alterne entre os temas claro e escuro.
8. Feche e abra o aplicativo para verificar a persistência dos dados.
9. Teste o isolamento das tarefas entre contas diferentes.
10. Utilize uma conta de teste para verificar a exclusão da conta.

## Capturas de tela

As capturas demonstrando as funcionalidades estão disponíveis na pasta `screenshots/`.

## Objetivo acadêmico

Projeto desenvolvido como atividade acadêmica para aplicação prática de desenvolvimento mobile com Flutter, persistência de dados, autenticação, gerenciamento de estado e integração com Firebase.

:::