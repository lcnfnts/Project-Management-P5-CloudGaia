@IsTest
public class Test_PendingTasksWrapper {
    
    @IsTest
    public static void testGetTasks() {
        // Create a test project and related tasks
        Project__c testProject = new Project__c(Name = 'Test Project',
                                                Start_Date__c = Date.today().addDays(2),
                                                Close_Date__c = Date.today().addDays(4));
        insert testProject;
        
        User u = [SELECT Id from User LIMIT 1];
        
        Project_Resource__c pr = new Project_Resource__c(Project__c = testProject.Id,
                                                         Resource__c = u.Id,
                                                         Start_Date__c = Date.today().addDays(2),
                                                         Close_Date__c = Date.today().addDays(4),
                                                         AssignedHours__c = 20);
        insert pr;
        
        Project_Task__c task1 = new Project_Task__c(
            Summary__c = 'Task 1',
            Status__c = 'In Progress',
            Project_Resource__c = pr.Id,
            Start_Date__c = Date.today().addDays(3),
            Close_Date__c = Date.today().addDays(4),
            Estimated_Hours__c = 3
        );
        Project_Task__c task2 = new Project_Task__c(
            Summary__c = 'Task 2',
            Status__c = 'Not Started',
            Project_Resource__c = pr.Id,
            Start_Date__c = Date.today().addDays(3),
            Close_Date__c = Date.today().addDays(4),
            Estimated_Hours__c = 3
        );
        insert task1;
        insert task2;
        System.debug(task1);
        
        // Call the getTasks method
        Test.startTest();
        PendingTasksWrapper result = PendingTasksWrapper.getTasks(testProject.Id);
        System.debug(result);
        System.debug(result.tasks);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(2, result.tasks.size(), 'Incorrect number of tasks');
        System.assertEquals(true, result.hasTasks, 'hasTasks should be true');
    }
}