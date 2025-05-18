@isTest
private class StringMatchUtilsTest {
    @isTest
    static void testExtractDomainFromEmail() {
        String email = 'user@example.com';
        String domain = StringMatchUtils.extractDomain(email);
        System.assertEquals('example.com', domain);
    }

    @isTest
    static void testExtractDomainFromURL() {
        String url = 'https://www.example.com/page';
        String domain = StringMatchUtils.extractDomain(url);
        System.assertEquals('example.com', domain);
    }

     // Test Jaro-Winkler similarity with whitespace and casing differences
    @isTest
    static void testJaroWinklerWithCasingWhitespace() {
        Double sim = StringMatchUtils.jaroWinkler(' company ltd ', 'Company Ltd');
        System.assert(sim > 0.85);
    }

    @isTest
    static void testJaroWinklerSimilarity() {
        Double similarityScore = StringMatchUtils.jaroWinkler('hello', 'hello');
        System.assertEquals(1.0, similarityScore);

        Double similarityScore2 = StringMatchUtils.jaroWinkler('hello', 'hell');
        System.assert(similarityScore2 < 1.0 && similarityScore2 > 0.0);

        Double similarityScore3 = StringMatchUtils.jaroWinkler(null, 'hello');
        System.assertEquals(0.0, similarityScore3);

        Double similarityScore4 = StringMatchUtils.jaroWinkler('', '');
        System.assertEquals(1.0, similarityScore4);

        Double similarityScore5 = StringMatchUtils.jaroWinkler('xello', 'hello');
        System.assert(similarityScore5 < 1.0 && similarityScore5 > 0.0);
    }
} 