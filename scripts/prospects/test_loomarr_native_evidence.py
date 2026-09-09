import runpy
import unittest
from pathlib import Path

inspect_commands = runpy.run_path(str(Path(__file__).with_name('loomarr-native-evidence.py')))['inspect_commands']


class NativeEvidenceTest(unittest.TestCase):
    def test_compiler_is_wrapped_and_linker_is_not(self):
        entries = [
            {'output': 'app.o', 'command': '/tmp/ccache clang++ -c app.cpp -o app.o'},
            {'output': 'libapp.so', 'command': 'clang++ -shared app.o -o libapp.so'},
        ]
        self.assertEqual(inspect_commands(entries, True), 1)

    def test_duplicate_launcher_is_rejected(self):
        with self.assertRaises(ValueError):
            inspect_commands([{'output': 'app.o', 'command': 'ccache ccache clang++ -c app.cpp'}], True)

    def test_missing_launcher_is_rejected(self):
        with self.assertRaises(ValueError):
            inspect_commands([{'output': 'app.o', 'command': 'clang++ -c app.cpp'}], True)

    def test_linker_launcher_is_rejected(self):
        with self.assertRaises(ValueError):
            inspect_commands([
                {'output': 'app.o', 'command': 'ccache clang++ -c app.cpp'},
                {'output': 'libapp.so', 'command': 'ccache clang++ -shared app.o'},
            ], True)

    def test_baseline_rejects_compiler_cache(self):
        with self.assertRaises(ValueError):
            inspect_commands([{'output': 'app.o', 'command': 'ccache clang++ -c app.cpp'}], False)

    def test_empty_graph_is_rejected(self):
        with self.assertRaises(ValueError):
            inspect_commands([], True)


if __name__ == '__main__':
    unittest.main()
