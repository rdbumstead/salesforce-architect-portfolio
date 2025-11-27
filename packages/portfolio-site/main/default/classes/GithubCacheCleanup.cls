global class GithubCacheCleanup implements Database.Batchable<SObject>, Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GithubCacheCleanup());
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime cutoff = Datetime.now().addHours(-2);
        return Database.getQueryLocator('SELECT Id FROM Github_Cache__c WHERE CreatedDate < :cutoff');
    }

    global void execute(Database.BatchableContext bc, List<Github_Cache__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext bc) {
        Database.executeBatch(new JiraCacheCleanup());
    }
}