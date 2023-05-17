trigger ProjectTaskTrigger on Project_Task__c (before insert, before update, after insert, after update, after delete) {
	if(Trigger.isBefore && (Trigger.isInsert)){
        Project_Task_Helper.validateFields(Trigger.new);
    } // Ver tema del update
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Project_Task_Helper.updateProjectResourceField(Trigger.new);
        }else if(Trigger.isDelete){
            Project_Task_Helper.updateProjectResourceField(Trigger.old);
        }
    }
}