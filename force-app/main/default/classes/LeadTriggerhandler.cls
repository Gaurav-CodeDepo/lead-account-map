public with sharing class LeadTriggerhandler {
    public static void beforeInsert(List<lead> newLeads) {
        if(newLeads.isEmpty()) return;
        LeadAccountMatcher.matchleadsToAccount(newleads);
    }
}