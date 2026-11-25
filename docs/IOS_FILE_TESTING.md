# Validação de arquivos no iOS

As correções estão na `developer`. O lançamento iOS aguarda a validação no Mac e
no aparelho; a publicação Android segue a validação no Android. Compilação iOS,
testes XCTest e compartilhamento real ainda não
foram executados no ambiente Windows usado para implementar estas mudanças.

Verificações locais concluídas: 624 testes Flutter aprovados, análise estática
dos arquivos Dart alterados sem problemas, plist e referências de fontes do
Xcode consistentes, e compilação web em modo release concluída. Os oito testes
XCTest e os cenários reais abaixo continuam pendentes no Mac/iPhone.

## Preparar o Mac

Use Flutter 3.41.9, a versão usada nas verificações do projeto, e Xcode instalado
e selecionado. Siga os ajustes solicitados por `flutter doctor -v`, incluindo
licença do Xcode, ferramentas iOS e CocoaPods quando necessário.

```sh
git switch developer
git pull --ff-only origin developer
flutter --version
flutter doctor -v
flutter pub get
flutter devices
```

Abra `ios/Runner.xcworkspace` no Xcode. Em Runner > Signing & Capabilities,
selecione a equipe de desenvolvimento da conta Apple usada para o teste e
confira o Bundle Identifier. O projeto ainda tem o identificador de exemplo
`com.example.dndCharacterTool`: use um identificador disponível para essa equipe
se o provisionamento exigir. A equipe e os certificados devem ser configurados
no Mac.

Conecte o iPhone, confie no Mac e habilite o Modo de Desenvolvedor quando o iOS
solicitar. Substitua o identificador abaixo pelo que `flutter devices` mostrar:

```sh
flutter run -d ID_DO_IPHONE
```

Para testar o app encerrado, use uma build que abra sem a sessão do depurador:

```sh
flutter run --release -d ID_DO_IPHONE
```

## Testes nativos e Flutter

```sh
flutter test
flutter analyze
```

No Xcode, selecione um simulador iPhone ou iPad e execute Product > Test
(Command-U). `RunnerTests` contém oito testes para as duas ordens de inicialização,
fichas/backups com extensão em maiúsculas, ordem de entrega, arquivos inválidos,
leitura em segundo plano, notificação na thread principal e leitura UTF-8 real.

Também é possível executar no terminal, após escolher um simulador disponível:

```sh
xcrun simctl list devices available
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -destination 'platform=iOS Simulator,id=ID_DO_SIMULADOR' test
```

Os testes nativos não substituem a folha de compartilhamento nem as permissões
dos provedores de arquivos reais; execute os cenários abaixo no iPhone.

## Exportar e importar

Prepare personagens de 2014 e 2024 com nome acentuado, foto, equipamento,
magias e notas. Anote os valores antes dos testes. O conteúdo de 2024 continua
em beta; aqui a verificação é de preservação de dados.

- [ ] Exporte um personagem em `.dndchar` e use Salvar em Arquivos, primeiro
  em No Meu iPhone e depois no iCloud Drive.
- [ ] Exporte todos os personagens em `.dndbackup` pelas configurações.
- [ ] Importe cada arquivo pelo seletor de arquivos do próprio app.
- [ ] Abra um `.dndchar` pelo app Arquivos com o DnD Character Tool já aberto.
- [ ] Repita com um `.dndbackup`.
- [ ] Encerre o DnD Character Tool pelo seletor de apps e abra cada tipo pelo
  app Arquivos. A tela deve iniciar e pedir confirmação uma única vez.
- [ ] Repita com um arquivo do iCloud ainda não baixado. A interface deve
  continuar respondendo durante o acesso ao provedor.
- [ ] Envie os dois tipos do Mac por AirDrop ou Mail e abra no iPhone.
- [ ] Receba dois arquivos em sequência. As confirmações devem aparecer uma
  por vez, sem perder um arquivo nem duplicar a importação.
- [ ] Cancele o seletor, a confirmação de importação e a folha de exportação.
  Nenhum personagem deve mudar, e exportação cancelada não deve mostrar sucesso.
- [ ] Se houver personagens aguardando atualização, cancele o compartilhamento
  oferecido: a atualização deve continuar, com uma cópia anterior às mudanças
  acessível em Configurações > Backups locais.
- [ ] Crie quatro backups locais e confira que apenas os três mais recentes
  aparecem. Exporte um deles e restaure outro como cópias, conferindo as fotos.
- [ ] Escolha um arquivo inválido no seletor: o app deve informar erro sem
  alterar os personagens existentes. Um arquivo externo sem conteúdo de ficha
  ou backup pode ser ignorado antes de abrir a confirmação.
- [ ] Confira nome, foto, regras, classes, PV, inventário, magias e notas após
  importar. Novos IDs e novas cópias são esperados; os originais devem permanecer.

## Intercâmbio com Android e iPad

- [ ] Android → iOS: exporte ficha e backup no Android, transfira por Arquivos,
  Mail ou aplicativo de mensagens e importe no iPhone.
- [ ] iOS → Android: faça o caminho inverso e confira os mesmos dados e fotos.
- [ ] No iPad ou no simulador iPad, abra a folha de exportação do personagem,
  do backup e do compartilhamento opcional da manutenção. O popover deve aparecer
  corretamente; cancelar e tentar novamente deve funcionar.

## Registrar o resultado antes do lançamento

Anote o commit testado, modelo do aparelho, versão do iOS, versão do Xcode,
provedor de arquivos e resultado dos cenários. Registre separadamente falhas
de compilação e falhas em tempo de execução, com os logs do Xcode quando houver.
Após a validação, promova `developer` para `main` pelo fluxo manual de lançamento.
