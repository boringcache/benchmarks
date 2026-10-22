import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.HexFormat;
import java.util.Map;
import java.util.Set;

public class JavaCaTrust {
    private static final Set<String> DISTRUSTED_ROOTS = Set.of(
        "86a1ecba089c4a8d3bbe2734c612ba341d813e043cf9e8a862cd5c57a36bbe6b",
        "d7a7a0fb5d7e2731d771e9484ebcdef71d5f0c3e0a2948782bc83ee0ea699ef4"
    );
    private static final char[] STORE_PASSWORD = "changeit".toCharArray();

    public static void main(String[] args) throws Exception {
        boolean apply = false;
        Path store = Path.of(System.getProperty("java.home"), "lib", "security", "cacerts");
        for (int index = 0; index < args.length; index++) {
            if (args[index].equals("--apply")) {
                apply = true;
            } else if (args[index].equals("--store") && index + 1 < args.length) {
                store = Path.of(args[++index]);
            } else {
                throw new IllegalArgumentException("Usage: JavaCaTrust.java [--apply] [--store PATH]");
            }
        }
        store = store.toRealPath();
        byte[] original = Files.readAllBytes(store);
        KeyStore certificates = KeyStore.getInstance(store.toFile(), STORE_PASSWORD);
        Map<String, String> before = fingerprints(certificates);
        Map<String, String> expected = new HashMap<>(before);
        expected.entrySet().removeIf(entry -> DISTRUSTED_ROOTS.contains(entry.getValue()));
        int removed = before.size() - expected.size();
        if (removed == 0) {
            System.out.println("Java trust store rejects the two affected root fingerprints.");
            return;
        }
        if (!apply) {
            throw new IllegalStateException("Java trust store contains " + removed + " affected root certificates.");
        }
        for (String alias : before.keySet()) {
            if (!expected.containsKey(alias)) certificates.deleteEntry(alias);
        }
        Path candidate = Files.createTempFile(store.getParent(), "cacerts-emudhra-", ".tmp");
        try {
            Files.copy(store, candidate, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.COPY_ATTRIBUTES);
            try (var output = Files.newOutputStream(candidate)) {
                certificates.store(output, STORE_PASSWORD);
            }
            if (!fingerprints(KeyStore.getInstance(candidate.toFile(), STORE_PASSWORD)).equals(expected)) {
                throw new IllegalStateException("Candidate changed unrelated trust entries; original store is unchanged.");
            }
            if (!MessageDigest.isEqual(original, Files.readAllBytes(store))) {
                throw new IllegalStateException("Trust store changed concurrently; candidate was not applied.");
            }
            Path backup = store.resolveSibling(store.getFileName() + ".before-emudhra-20261021");
            Files.copy(store, backup, StandardCopyOption.COPY_ATTRIBUTES);
            Files.move(candidate, store, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            System.out.println("Removed " + removed + " affected Java root certificates; backup: " + backup);
        } finally {
            Files.deleteIfExists(candidate);
        }
    }

    private static Map<String, String> fingerprints(KeyStore store) throws Exception {
        Map<String, String> result = new HashMap<>();
        var aliases = store.aliases();
        while (aliases.hasMoreElements()) {
            String alias = aliases.nextElement();
            if (!store.isCertificateEntry(alias)) {
                throw new IllegalStateException("Refusing a store containing non-certificate entries.");
            }
            byte[] encoded = store.getCertificate(alias).getEncoded();
            result.put(alias, HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(encoded)));
        }
        if (result.isEmpty()) throw new IllegalStateException("Refusing an empty trust store.");
        return result;
    }
}
