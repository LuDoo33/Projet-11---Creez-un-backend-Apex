@isTest
private class AccountFollowUpBatchSchedulerTest {
    @isTest
    static void testSchedulerExecution() {
        // Planification avec une expression cron qui s'exécute dans 1 minute
        String cronExp = '0 ' + (Datetime.now().minute() + 1) + ' ' + Datetime.now().hour() + ' ' + Datetime.now().day() + ' ' + Datetime.now().month() + ' ? ' + Datetime.now().year();
        
        // Planification du job avec l'expression CRON
        AccountFollowUpBatchScheduler scheduler = new AccountFollowUpBatchScheduler();
        System.schedule('TestScheduleJob', cronExp, scheduler);
        
        // Vérifier que le job a été planifié
        List<CronTrigger> cronJobs = [SELECT Id, CronExpression, TimesTriggered, State FROM CronTrigger WHERE CronJobDetail.Name = 'TestScheduleJob'];
        System.assertEquals(1, cronJobs.size(), 'Le job planifié n\'a pas été trouvé.');
        
        // Vérifier que le job est dans l'état "WAITING"
        System.assertEquals('WAITING', cronJobs[0].State, 'Le job n\'est pas dans l\'état "WAITING".');
        
        // Simuler l'exécution immédiate du batch dans l'environnement de test
        Test.startTest();
        // Nous forçons ici l'exécution du job batch
        Database.executeBatch(new AccountFollowUpBatch(), 1);
        Test.stopTest();
        
        // Vérifier que le batch a bien été exécuté
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assert(!jobs.isEmpty(), 'Le job de batch n\'a pas été exécuté.');
        
        // Vérifier le statut du job de batch
        System.assertEquals('Completed', jobs[0].Status, 'Le job de batch n\'a pas été exécuté avec succès.');
    }
}
