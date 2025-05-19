public class StringMatchUtils {
    
    /*
        Utility class for string comparison and domain extraction.
        Includes implementation of the Jaro-Winkler similarity algorithm,
        Calculates the Jaro-Winkler similarity between two strings.
        Returns a value between 0.0 (no similarity) and 1.0 (exact match).
     */
    public static String extractDomain(String input) {
        try {
            if (String.isBlank(input)) return null;

            input = input.toLowerCase().trim();

            // Handle email address
            if (input.contains('@')) {
                Integer atIndex = input.indexOf('@');
                if (atIndex >= 0 && atIndex < input.length() - 1) {
                    return input.substring(atIndex + 1);
                } else {
                    System.debug('Invalid email input for extractDomain: ' + input);
                    return null;
                }
            }

            // Handle URLs
            if (input.startsWith('http://')) input = input.replaceFirst('http://', '');
            if (input.startsWith('https://')) input = input.replaceFirst('https://', '');
            if (input.startsWith('www.')) input = input.replaceFirst('www.', '');

            Integer slashIndex = input.indexOf('/');
            if (slashIndex > 0) {
                input = input.substring(0, slashIndex);
            }

            return input;
        } catch (Exception e) {
            System.debug('Error in extractDomain with input: ' + input + ' | Exception: ' + e.getMessage());
            return null;
        }
    }

    public static Double jaroWinkler(String s1, String s2) {
        try {
            if (s1 == null || s2 == null) return 0.0;

            s1 = s1.toLowerCase();
            s2 = s2.toLowerCase();

            if (s1 == s2) return 1.0;

            Integer len1 = s1.length();
            Integer len2 = s2.length();

            if (len1 == 0 || len2 == 0) return 0.0;

            Integer matchDistance = Integer.valueOf(Math.floor(Math.max(len1, len2) / 2)) - 1;

            Boolean[] s1Matches = new Boolean[len1];
            Boolean[] s2Matches = new Boolean[len2];

            Integer matches = 0;
            for (Integer i = 0; i < len1; i++) {
                Integer start = Math.max(0, i - matchDistance);
                Integer endIdx = Math.min(i + matchDistance + 1, len2);

                for (Integer j = start; j < endIdx; j++) {
                    if (s2Matches[j] != true && s1.charAt(i) == s2.charAt(j)) {
                        s1Matches[i] = true;
                        s2Matches[j] = true;
                        matches++;
                        break;
                    }
                }
            }

            if (matches == 0) return 0.0;

            Double transpositions = 0;
            Integer k = 0;
            for (Integer i = 0; i < len1; i++) {
                if (s1Matches[i] == true) {
                    while (s2Matches[k] != true) k++;
                    if (s1.charAt(i) != s2.charAt(k)) transpositions++;
                    k++;
                }
            }

            Double m = matches;
            Double jaro = ((m / len1) + (m / len2) + ((m - (transpositions / 2)) / m)) / 3;

            // Jaro-Winkler boost for common prefix
            Integer prefix = 0;
            for (Integer i = 0; i < Math.min(4, Math.min(len1, len2)); i++) {
                if (s1.charAt(i) == s2.charAt(i)) prefix++;
                else break;
            }

            return jaro + (prefix * 0.1 * (1 - jaro));
        } catch (Exception e) {
            System.debug('Error in jaroWinkler comparison for s1: ' + s1 + ', s2: ' + s2 + ' | Exception: ' + e.getMessage());
            return 0.0;
        }
    }
}
