global class AccountFollowUpBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        AccountFollowUpBatch batch = new AccountFollowUpBatch();
        Database.executeBatch(batch, 200);
    }
}
