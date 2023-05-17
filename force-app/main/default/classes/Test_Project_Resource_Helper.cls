@isTest
public class Test_Project_Resource_Helper {
	@isTest
    private static void testOne(){
        Project__c p = new Project__c();
        p.Start_Date__c = Date.today();
        p.Close_Date__c = Date.today().addDays(40);
        insert p;
        
        Project_Product__c pp = new Project_Product__c(
        	Project__c = p.Id,
            Role__c = 'Developer',
            Quantity__c = 40
        );
        insert pp;
        
       	Project_Resource__c pr = new Project_Resource__c(
        	Project__c = p.Id,
            Resource__c = '005Dp000000OgubIAC',
            AssignedHours__c = 20,
            Start_Date__c = Date.today().addDays(2),
            Close_Date__c = Date.today().addDays(5)
        );
        test.startTest();
        	insert pr;
        test.stopTest();
        
        Project_Product__c testPP = [SELECT Id, Completed_Hours__c FROM Project_Product__c];
        System.assertEquals(20, testPP.Completed_Hours__c);
    }
    
    @isTest
    private static void testTwo(){
        Project__c p = new Project__c();
        insert p;
        
        Project_Product__c pp = new Project_Product__c(
        	Project__c = p.Id,
            Role__c = 'Developer',
            Quantity__c = 40
        );
        insert pp;
        
       	Project_Resource__c pr = new Project_Resource__c(
        	Project__c = p.Id,
            Resource__c = '005Dp000000OEChIAO',
            AssignedHours__c = 20,
            Start_Date__c = Date.today().addDays(2),
            Close_Date__c = Date.today().addDays(5)
        );
        insert pr;
        test.startTest();
          	delete pr;
        test.stopTest();
        
        Project_Product__c testPP = [SELECT Id, Completed_Hours__c FROM Project_Product__c];
        System.assertEquals(0, testPP.Completed_Hours__c);
    }
    
    @isTest
    private static void testThree(){
        Project__c p = new Project__c();
        insert p;
        
        Project_Product__c pp = new Project_Product__c(
        	Project__c = p.Id,
            Role__c = 'Developer',
            Quantity__c = 40
        );
        insert pp;
        
       	Project_Resource__c pr = new Project_Resource__c(
        	Project__c = p.Id,
            Resource__c = '005Do000001SJJHIA4',
            AssignedHours__c = 20,
            Start_Date__c = Date.today(),
            Close_Date__c = Date.today().addDays(5)
        );
        test.startTest();
            try{
        		insert pr;                
            }catch(Exception e){
                System.debug(e.getMessage());
            }

        test.stopTest();
        
        List<Project_Resource__c> testPr = [SELECT Id FROM Project_Resource__c];
        System.assertEquals(0, testPr.size());
    }
}