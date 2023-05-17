@isTest
public class Test_ProjectTaskService {
    @isTest private static void testUpdateTaskStatus(){
        Project_Task__c pt = new Project_Task__c();
        pt.Status__c = 'Not Started';
        pt.Estimated_Hours__c = 5;
        pt.Recorded_Hours__c = 5;
        insert pt;
        
        Project_Task__c pt2 = new Project_Task__c();
        pt.Status__c = 'Not Started';
        pt.Estimated_Hours__c = 5;
        pt.Recorded_Hours__c = 4;
        insert pt2;
        
        Test.startTest();
        ProjectTaskService.updateTaskStatus(pt.Id, 'In Progress');
        ProjectTaskService.updateTaskStatus(pt.Id, 'Completed');
        try{
        	ProjectTaskService.updateTaskStatus(pt2.Id, 'Completed');
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
        
        List<Project_Task__c> protask = [SELECT Id FROM Project_Task__c LIMIT 1];
        System.assertEquals(1, protask.size());
    }
    
    @isTest private static void testUpdateRecordedHours(){
        Project_Task__c pt = new Project_Task__c();
        pt.Status__c = 'Not Started';
        pt.Estimated_Hours__c = 5;
        pt.Recorded_Hours__c = 5;
        insert pt;
        
        Project_Task__c pt2 = new Project_Task__c();
        pt2.Status__c = 'Not Started';
        pt2.Estimated_Hours__c = 5;
        pt2.Recorded_Hours__c = 5;
        insert pt2;
        
        Project_Task__c pt3 = new Project_Task__c();
        pt3.Status__c = 'In Progress';
        pt3.Estimated_Hours__c = 5;
        pt3.Recorded_Hours__c = 0;
        insert pt3;
        
        Test.startTest();
        ProjectTaskService.updateRecordedHours(pt3.Id, 2);
        try{
        	ProjectTaskService.updateRecordedHours(pt.Id, -1);
        }catch(Exception e){
        }
        try{
        	ProjectTaskService.updateRecordedHours(pt2.Id, 2);
        }catch(Exception e){
        }
        Test.stopTest();
        
        // Muy necesario querearlo despues de actualizarlo
        Project_Task__c protask3 = [SELECT Id, Recorded_Hours__c FROM Project_Task__c WHERE Id = :pt3.Id];
        
        System.assertEquals(5, pt.Recorded_Hours__c);
        System.assertEquals(5, pt2.Recorded_Hours__c);
        System.assertEquals(2, protask3.Recorded_Hours__c);
        
        //System.assertEquals(expected, actual)
    }
}