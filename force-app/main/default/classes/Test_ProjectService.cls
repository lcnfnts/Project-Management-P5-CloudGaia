@isTest
public class Test_ProjectService {
    
    @isTest
    private static void testOne(){
      	/*{	
			"Project__c":"a01Do0000175yFaIAI",
			"Resource__c":"005Do000001SUJEIA4",
			"Start_Date__c":"2023-04-21",
			"Close_Date__c":"2023-04-24",
			"AssignedHours__c":20
		}*/
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Start_Date__c = Date.today().addDays(1);
        p.Close_Date__c = Date.today().addDays(100);
        
        insert p;
        
        User u = [SELECT Id FROM User LIMIT 1];
        
        String jsonString = '[{"Project__c":"'+String.ValueOf(p.Id)+'","Resource__c":"'+String.ValueOf(u.Id)+'","Start_Date__c":"'+String.ValueOf(Date.today().addDays(2))+'","Close_Date__c":"'+String.ValueOf(Date.today().addDays(4))+'","AssignedHours__c":"3"}]';
        
        Test.startTest();
        ProjectService.addResources(p.Id, jsonString);
        Test.stopTest();
        
        List<Project_Resource__c> pr = [SELECT Id, Project__c FROM Project_Resource__c LIMIT 1];
        System.assert(pr.size() > 0);
        System.assert(pr[0].Project__c == p.Id);
    }

}