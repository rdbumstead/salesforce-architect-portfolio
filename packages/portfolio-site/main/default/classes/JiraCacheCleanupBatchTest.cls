@IsTest
private class JiraCacheCleanupBatchTest {

    @IsTest
    static void testJiraCleanup_deletesOldRecords() {
        Datetime oldJiraTime = Datetime.now().addMinutes(-45);
        Datetime newJiraTime = Datetime.now().addMinutes(-1);
        
        List<Jira_Cache__c> records = new List<Jira_Cache__c>();
        records.add(new Jira_Cache__c());
        records.add(new Jira_Cache__c());
        records.add(new Jira_Cache__c());
        
        insert records;
        
        Test.setCreatedDate(records[0].Id, oldJiraTime);
        Test.setCreatedDate(records[1].Id, oldJiraTime);
        Test.setCreatedDate(records[2].Id, newJiraTime);

        Test.startTest();
        Database.executeBatch(new JiraCacheCleanup());
        Test.stopTest();

        Integer countAfterDelete = [SELECT COUNT() FROM Jira_Cache__c];
        System.assertEquals(1, countAfterDelete, 'Only the recent Jira cache record should remain.');
    }
}