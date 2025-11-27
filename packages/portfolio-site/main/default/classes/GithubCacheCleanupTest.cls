@IsTest
private class GithubCacheCleanupTest {

    @IsTest
    static void testBatchExecution_deletesOldRecordsAndChainsJiraCleanup() {
        Datetime oldGitHubTime = Datetime.now().addHours(-3);
        Datetime oldJiraTime   = Datetime.now().addMinutes(-45);
        
        List<Github_Cache__c> ghRecords = new List<Github_Cache__c>{ new Github_Cache__c(), new Github_Cache__c() };
        insert ghRecords;

        List<Jira_Cache__c> jiraRecords = new List<Jira_Cache__c>{ new Jira_Cache__c(), new Jira_Cache__c() };
        insert jiraRecords;
        
        Test.setCreatedDate(ghRecords[0].Id, oldGitHubTime);
        Test.setCreatedDate(jiraRecords[0].Id, oldJiraTime);
        
        Test.startTest();
        Database.executeBatch(new GithubCacheCleanup());
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Github_Cache__c], 'The recent GitHub cache record should remain');
        System.assertEquals(1, [SELECT COUNT() FROM Jira_Cache__c],   'The recent Jira cache record should remain');
    }

    @IsTest
    static void testSchedulableExecution_schedulesBatchJob() {
        Test.startTest();
        String jobId = System.schedule('Test Portfolio Cache Cleanup', '0 0 0 1 1 ? 2050', new GithubCacheCleanup());
        Test.stopTest();
        
        Integer queuedJobs = [
            SELECT COUNT() 
            FROM AsyncApexJob 
            WHERE JobType = 'BatchApex'
              AND ApexClass.Name = 'GithubCacheCleanup'
              AND Status = 'Queued'
        ];
        
        System.assertNotEquals(null, jobId, 'Job should have been scheduled');
    }
}