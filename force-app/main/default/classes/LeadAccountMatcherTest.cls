@isTest
private class LeadAccountMatcherTest {

    // Tests matching logic based on exact email domain match
    @isTest
    static void testMatchWithEmailDomain() {
        Account acc = new Account(Name = 'Example', Website = 'example.com');
        insert acc;

        Lead lead = new Lead(LastName = 'Doe', Company = 'Exam Test Company', Email = 'john.doe@example.com');
        insert lead;

        Test.startTest();
        LeadAccountMatcher.matchLeadsToAccount(new List<Lead>{lead});
        Test.stopTest();

        System.assertEquals(acc.Id, lead.Matched_Account__c);
        System.assertEquals('Domain', lead.Matched_By__c);
        System.assertEquals(1.0, lead.Match_Score__c);
    }

    // Tests fuzzy matching logic using company name similarity
    @isTest
    static void testMatchWithFuzzyCompany() {
        Account acc = new Account(Name = 'United Technologies');
        insert acc;

        Lead lead = new Lead(LastName = 'Doe', Company = 'United Tech', Email = 'john@unknown.com');
        insert lead;

        Test.startTest();
        LeadAccountMatcher.matchLeadsToAccount(new List<Lead>{lead});
        Test.stopTest();

        System.assertEquals(acc.Id, lead.Matched_Account__c);
        System.assertEquals('Fuzzy', lead.Matched_By__c);
        System.assert(lead.Match_Score__c >= 0.85);
    }

    // Tests match prioritization when both domain and company name match
    @isTest
    static void testCombinedMatchPriority() {
        Account acc = new Account(Name = 'Combined Tech', Website = 'combined.com');
        insert acc;

        Lead lead = new Lead(LastName = 'Doe', Company = 'Combined Tech', Email = 'john@combined.com');
        insert lead;

        Test.startTest();
        LeadAccountMatcher.matchLeadsToAccount(new List<Lead>{lead});
        Test.stopTest();

        System.assertEquals(acc.Id, lead.Matched_Account__c);
        System.assertEquals('Combined', lead.Matched_By__c);
        System.assertEquals(1.0, lead.Match_Score__c);
    }

    // Tests behavior when no matching account is found
    @isTest
    static void testNoMatch() {
        Lead lead = new Lead(LastName = 'Rob', Company = 'William', Email = 'noone@nomatch.com');
        insert lead;

        Test.startTest();
        LeadAccountMatcher.matchLeadsToAccount(new List<Lead>{lead});
        Test.stopTest();

        System.assertEquals(null, lead.Matched_Account__c);
        System.assertEquals(null, lead.Matched_By__c);
        System.assertEquals(null, lead.Match_Score__c);
    }
}