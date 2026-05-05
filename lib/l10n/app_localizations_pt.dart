// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'D&D Character Tool';

  @override
  String get charListTitle => 'Personagens D&D';

  @override
  String get charListImportTooltip => 'Importar JSON';

  @override
  String get charListSettingsTooltip => 'Configurações';

  @override
  String get charListNewCharacter => 'Novo Personagem';

  @override
  String get charListEmpty => 'Nenhum personagem ainda';

  @override
  String get charListEmptyHint =>
      'Toque em + para criar seu primeiro personagem';

  @override
  String charListImportedSuccess(String name) {
    return '$name importado com sucesso!';
  }

  @override
  String get charListImportError =>
      'Erro inesperado ao importar. Tente novamente.';

  @override
  String charCardLevel(int level) {
    return 'Nível $level';
  }

  @override
  String get charCardPin => 'Fixar no topo';

  @override
  String get charCardUnpin => 'Desafixar';

  @override
  String get charCardChangePhoto => 'Alterar foto';

  @override
  String get charCardRename => 'Renomear';

  @override
  String get charCardExport => 'Exportar';

  @override
  String get charCardDelete => 'Excluir';

  @override
  String get renameDialogTitle => 'Renomear personagem';

  @override
  String get renameDialogLabel => 'Nome';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogSave => 'Salvar';

  @override
  String get deleteDialogTitle => 'Excluir personagem?';

  @override
  String deleteDialogContent(String name) {
    return 'Tem certeza que deseja excluir $name? Esta ação não pode ser desfeita.';
  }
}
