@isTest
private class AccountFollowUpBatchSchedulerTest {
    @isTest
    static void testSchedulerExecution() {
        // 1. Planifie le job avec une expression cron valide
        AccountFollowUpBatchScheduler scheduler = new AccountFollowUpBatchScheduler();
        String cronExpression = '0 0 0 * * ?';  // Exécution à minuit tous les jours
        System.schedule('Test Scheduler', cronExpression, scheduler);

        // 2. Démarre la simulation du test
        Test.startTest();
        
        // 3. Lance la méthode d'exécution du batch (pour simuler son exécution immédiate dans le test)
        Database.executeBatch(new AccountFollowUpBatch());
        
        // 4. Arrête la simulation du test
        Test.stopTest();
        
        // 5. Vérifie le statut du job de batch
        List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE ApexClass.Name = 'AccountFollowUpBatch' ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('Completed', jobs[0].Status, 'Le job de batch n\'a pas été exécuté avec succès.');
    }
}
