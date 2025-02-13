@isTest
private class AccountFollowUpBatchSchedulerTest {
    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        
        AccountFollowUpBatchScheduler scheduler = new AccountFollowUpBatchScheduler();
        
        // Expression CRON valide qui s'exécute 1 minute après l'heure courante
        String cronExp = '0 ' + (Datetime.now().minute() + 1) + ' ' + Datetime.now().hour() + ' ' + Datetime.now().day() + ' ' + Datetime.now().month() + ' ? ' + Datetime.now().year();
        
        System.schedule('TestScheduleJob', cronExp, scheduler);
        
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assert(!jobs.isEmpty(), 'Le job de batch n\'a pas été exécuté.');
    }
}
