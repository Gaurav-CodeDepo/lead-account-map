public class LeadAccountMatcher {
    public static void matchLeadsToAccount(List<Lead> leads) {
        try {
            Set<String> emailDomains = new Set<String>();

            // Step 1: Collect normalized email domains from Leads
            for (Lead l : leads) {
                try {
                    if (l.Email != null && l.Email.contains('@')) {
                        String normalizedEmail = StringMatchUtils.extractDomain(l.Email);
                        if (normalizedEmail != null) {
                            emailDomains.add(normalizedEmail.toLowerCase());
                        }
                    }
                } catch (Exception e) {
                    System.debug('Error processing Lead email for domain extraction: ' + e.getMessage());
                }
            }

            // Step 2: Retrieve all Accounts with non-null Website or Name
            List<Account> accounts = new List<Account>();
            try {
                accounts = [
                    SELECT Id, Name, Website
                    FROM Account
                    WHERE Website != null OR Name != null
                ];
            } catch (Exception e) {
                System.debug('Error retrieving Accounts: ' + e.getMessage());
                return; // Cannot proceed without Accounts
            }

            // Step 3: Map normalized Account website domains to Account records
            Map<String, Account> domainAccountMap = new Map<String, Account>();
            for (Account acc : accounts) {
                try {
                    String normalizedWebsite = StringMatchUtils.extractDomain(acc.Website);
                    if (normalizedWebsite != null && !domainAccountMap.containsKey(normalizedWebsite)) {
                        domainAccountMap.put(normalizedWebsite, acc);
                    }
                } catch (Exception e) {
                    System.debug('Error processing Account website domain: ' + e.getMessage());
                }
            }

            // Step 4: Try to match each Lead to an Account
            for (Lead l : leads) {
                try {
                    Account matchedByDomain = null;
                    Account matchedByFuzzy = null;
                    Double fuzzyScore = 0.0;

                    String normalizedEmail = (l.Email != null && l.Email.contains('@')) ? 
                        StringMatchUtils.extractDomain(l.Email) : null;

                    // First: Domain-based match
                    if (normalizedEmail != null && domainAccountMap.containsKey(normalizedEmail)) {
                        matchedByDomain = domainAccountMap.get(normalizedEmail);
                    }

                    // Second: Fuzzy match Lead.Company with Account.Name
                    if (l.Company != null) {
                        Double maxScore = 0.0;
                        for (Account acc : accounts) {
                            Double similarityScore = StringMatchUtils.jaroWinkler(l.Company, acc.Name);
                            if (similarityScore > maxScore && similarityScore >= 0.85) {
                                matchedByFuzzy = acc;
                                maxScore = similarityScore;
                            }
                        }
                        fuzzyScore = maxScore;
                    }

                    // Decide final match result
                    if (matchedByDomain != null && matchedByFuzzy != null && matchedByDomain.Id == matchedByFuzzy.Id) {
                        l.Matched_Account__c = matchedByDomain.Id;
                        l.Matched_By__c = 'Combined';
                        l.Match_Score__c = fuzzyScore;
                    } else if (matchedByDomain != null) {
                        l.Matched_Account__c = matchedByDomain.Id;
                        l.Matched_By__c = 'Domain';
                        l.Match_Score__c = 1.0;
                    } else if (matchedByFuzzy != null) {
                        l.Matched_Account__c = matchedByFuzzy.Id;
                        l.Matched_By__c = 'Fuzzy';
                        l.Match_Score__c = fuzzyScore;
                    }

                } catch (Exception e) {
                    System.debug('Error matching Lead Id: ' + l.Id + ' - ' + e.getMessage());
                }
            }

        } catch (Exception e) {
            System.debug('Unexpected error in matchLeadsToAccount: ' + e.getMessage());
        }
    }
}