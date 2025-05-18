@isTest
private class LeadTriggerTest {
    @isTest
    static void testLeadTriggerBeforeInsert() {
        Account acc = new Account(Name = 'Trigger Test Account', Website = 'trigger.com');
        insert acc;

        Lead lead = new Lead(LastName = 'Trigger', Company = 'Trigger Test Account', Email = 'trigger@trigger.com');

        Test.startTest();
        insert lead;
        Test.stopTest();

        lead = [SELECT Matched_Account__c, Matched_By__c, Match_Score__c FROM Lead WHERE Id = :lead.Id];

        System.assertEquals('Combined', lead.Matched_By__c);
        System.assertEquals(acc.Id, lead.Matched_Account__c);
        System.assertEquals(1.0, lead.Match_Score__c);
    }
}