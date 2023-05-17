trigger Project_Resource_Trigger on Project_Resource__c (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        Project_Resource_Helper.updateName(Trigger.new);
        Project_Resource_Helper.checkDatesRange(Trigger.new);
    }
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        Project_Resource_Helper.updateCompletedHours(Trigger.new);
    }
    if(Trigger.isDelete && Trigger.isAfter){
        Project_Resource_Helper.updateCompletedHours(Trigger.old);
    }
}