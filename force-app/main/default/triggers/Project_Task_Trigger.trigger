trigger Project_Task_Trigger on Project_Task__c (after insert, after update, after delete) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        Project_Task_Helper.sumUncompletedTasks(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        Project_Task_Helper.sumUncompletedTasks(Trigger.old);
    }
}