public class LeadAccountMatcher {
    public static void matchLeadsToAccount(List<Lead> leads) {
        Set<String> emailDomains = new Set<String>();

        // Step 1: Collect normalized email domains from Leads
        for (Lead l : leads) {
            if (l.Email != null && l.Email.contains('@')) {
                // Extract and normalize email domain from lead email (e.g., example.com)
                String normalizedEmail = StringMatchUtils.extractDomain(l.Email);
                if (normalizedEmail != null) {
                    emailDomains.add(normalizedEmail.toLowerCase());
                }
            }
        }

        // Step 2: Retrieve all Accounts with non-null Website or Name
        List<Account> accounts = [
            SELECT Id, Name, Website
            FROM Account
            WHERE Website != null OR Name != null
        ];

        // Step 3: Map normalized Account website domains to Account records
        Map<String, Account> domainAccountMap = new Map<String, Account>();
        for (Account acc : accounts) {
            String normalizedWebsite = StringMatchUtils.extractDomain(acc.Website);
            if (normalizedWebsite != null && !domainAccountMap.containsKey(normalizedWebsite)) {
                domainAccountMap.put(normalizedWebsite, acc);
            }
        }

        // Step 4: Try to match each Lead to an Account
        for (Lead l : leads) {
            Account matchedByDomain = null;
            Account matchedByFuzzy = null;
            Double fuzzyScore = 0.0;

            // Extract normalized email domain again for matching
            String normalizedEmail = (l.Email != null && l.Email.contains('@')) ? 
                StringMatchUtils.extractDomain(l.Email) : null;

            // First: Match based on domain
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

            // Determine best match type and populate Lead fields
            if (matchedByDomain != null && matchedByFuzzy != null && matchedByDomain.Id == matchedByFuzzy.Id) {
                // Combined match
                l.Matched_Account__c = matchedByDomain.Id;
                l.Matched_By__c = 'Combined';
                l.Match_Score__c = fuzzyScore;
            } else if (matchedByDomain != null) {
                // Only domain match
                l.Matched_Account__c = matchedByDomain.Id;
                l.Matched_By__c = 'Domain';
                l.Match_Score__c = 1.0;
            } else if (matchedByFuzzy != null) {
                // Only fuzzy match
                l.Matched_Account__c = matchedByFuzzy.Id;
                l.Matched_By__c = 'Fuzzy';
                l.Match_Score__c = fuzzyScore;
            }
        }
    }
}