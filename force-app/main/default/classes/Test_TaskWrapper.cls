@isTest
public class Test_TaskWrapper {
    
    @isTest
    static void testGetTaskWrapper() {
        // Create test data
        // 
 
        User u = [SELECT Id FROM User LIMIT 1];
        
        
        Project__c p1 = new Project__c(Close_Date__c = Date.today(),
                                       Start_Date__c = Date.today().addDays(7)
                                       );
        
        insert p1;
  
        Project_Resource__c pr1 =  new Project_Resource__c(
            Project__c = p1.Id,
            Resource__c = userInfo.getUserId(),
            AssignedHours__c = 20,
            Start_Date__c = Date.today().addDays(3),
            Close_Date__c = Date.today().addDays(6)
        );
        
        insert pr1;
        
        p1.Squad_Lead__c = pr1.Id;
        p1.OwnerId = u.Id;
        update p1;
        
        Project_Task__c t1 = new Project_Task__c(Project_Resource__c= pr1.Id,
                                                 Estimated_Hours__c=10,
                                                 Recorded_Hours__c = 1,
                                                 Summary__c= 'hola',
                                                 Close_Date__c = Date.today().addDays(5),
                                                 Start_Date__c = Date.today().addDays(4),
                                                 Status__c= 'In Progress');
       
        insert t1;
        
        Project_Task__c t2 = new Project_Task__c(Project_Resource__c= pr1.Id,
                                                 Estimated_Hours__c=10,
                                                 Recorded_Hours__c =10,
                                                 Summary__c= 'hola',
                                                 Close_Date__c = Date.today().addDays(5),
                                                 Start_Date__c = Date.today().addDays(4),
                                                 Status__c = 'Completed');
        insert t2;
        
       
          
        Test.startTest();
        TaskWrapper wrapper = TaskWrapper.getTaskWrapper();
          System.debug(wrapper);
          System.debug(p1);
          System.debug(pr1);
          System.debug(t1);
          System.debug(t2);
        Test.stopTest();

        // Assert results
        
        System.assertEquals(true, wrapper.hasTasks, 'Expected to have tasks');
        System.assertEquals(1, wrapper.projectWithTasks.size(), 'Expected to have 1 projects with tasks');
      
       
    }
}