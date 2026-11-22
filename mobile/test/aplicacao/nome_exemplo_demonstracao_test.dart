// A demonstração mostra o exemplo real 1 com o nome corrigido; o arquivo de
// referência, cópia do que a pedaleira gravou, continua como veio.
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('should_show_the_corrected_name_of_the_real_example_in_the_demonstration', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final presets = await container.read(presetsDemonstracaoProvider.future);

    expect((presets[1]!['preset'] as Map)['name'], 'My favorite tone');
    expect(lerExemplo('1')['preset']['name'], 'My faorite tone', reason: 'a referência real não muda');
  });
}
