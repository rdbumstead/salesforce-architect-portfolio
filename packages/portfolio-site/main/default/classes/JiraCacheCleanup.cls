global class JiraCacheCleanup implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime cutoffJira = Datetime.now().addMinutes(-30);
        String query = 'SELECT Id FROM Jira_Cache__c WHERE CreatedDate < :cutoffJira';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Jira_Cache__c> records) {
        if (!records.isEmpty()) {
            delete records;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}