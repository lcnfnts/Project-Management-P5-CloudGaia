public class ProjectTaskService {
    @AuraEnabled
    public static void updateTaskStatus(id taskId, String status){
        Project_Task__c task = [SELECT Id, Status__c, Estimated_Hours__c, Recorded_Hours__c FROM Project_Task__c WHERE Id = :taskId];        
        if(status == 'In progress'){
            task.Status__c = status;
            update task;            
        }else if(status == 'Completed' && task.Estimated_Hours__c == task.Recorded_Hours__c){
            task.Status__c = status;
            update task;
        }else{
            throw new CustomDatesException('You have not completed the mandatory hours');
        }    
    }
    
    @AuraEnabled
    public static void updateRecordedHours(Id taskId, Integer recordedHours){
        if(recordedHours < 0){
            throw new CustomDatesException('Invalid recorded hours number');            
        }
        Project_Task__c task = [SELECT Id, Status__c, Estimated_Hours__c, Recorded_Hours__c FROM Project_Task__c WHERE Id = :taskId]; 
        if((recordedHours + task.Recorded_Hours__c) > task.Estimated_Hours__c){
            throw new CustomDatesException('You cannot add more hours than the estimated total');            
        }else{
            task.Recorded_Hours__c = task.Recorded_Hours__c + recordedHours;
            update task;
        }      
    }
}