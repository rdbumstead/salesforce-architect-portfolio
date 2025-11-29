@IsTest
private class JiraCacheCleanupBatchTest {

    @IsTest
    static void testJiraBatchDeletesExpiredRecords() {
        CacheCleanupSettings.testOverrideEnabled = false;

        CacheCleanupTestDataFactory.createJiraCache(10);

        for (Jira_Cache__c rec : [
            SELECT Id, CreatedDate FROM Jira_Cache__c
        ]) {
            Test.setCreatedDate(rec.Id, Datetime.now().addHours(-1));
        }

        Test.startTest();
        Database.executeBatch(new JiraCacheCleanupBatch(), 200);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Jira_Cache__c],
            'All expired Jira cache records should be deleted.'
        );
    }

    @IsTest
    static void testJiraBatchWhenDisabled() {
        CacheCleanupSettings.testOverrideEnabled = true;

        CacheCleanupTestDataFactory.createJiraCache(10);

        Test.startTest();
        Database.executeBatch(new JiraCacheCleanupBatch(), 200);
        Test.stopTest();

        System.assertEquals(
            10,
            [SELECT COUNT() FROM Jira_Cache__c],
            'No Jira cache records should be deleted when cleanup is disabled.'
        );
    }
}