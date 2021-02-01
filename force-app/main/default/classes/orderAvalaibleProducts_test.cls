@isTest (SeeAllData = true)
public with sharing class orderAvalaibleProducts_test {
    
    public class ProductWrapper {
        @AuraEnabled public String productName{get;set;}
        @AuraEnabled public Id productId{get;set;}
        @AuraEnabled public Decimal listPrice{get;set;}
        @AuraEnabled public Id PricebookEntryId{get;set;}
    }

    static testMethod void testAvalaibleProducts() {
        Account acc = new Account();
        acc.Name='Test1';
        
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name='Test2';
        
        insert acc2;
        
        
        Opportunity newOpp = new Opportunity();
        newOpp.Name = 'TEst';
        newOpp.StageName='Contratada';
        newOpp.CloseDate=Date.today();
        newOpp.AccountId = acc.Id;
        
        insert newOpp;
        
        Product2 newproduct =new Product2();
        newproduct.Name='test';
        newproduct.productCode='1234';
        newproduct.isActive = true;
        
        insert newproduct;
        
        Pricebook2 standard = [Select Id, Name, IsActive, IsStandard From Pricebook2 where IsStandard = true LIMIT 1];
        System.assertEquals(true, standard.IsStandard, standard.IsStandard );

        PricebookEntry pbeTest = new PricebookEntry();
        pbeTest.pricebook2Id = standard.id;
        pbeTest.product2id = newproduct.id;
        pbeTest.unitprice = 1249.0;
        pbeTest.isactive = true;
        insert pbeTest;     
        
        ProductWrapper pw = new ProductWrapper();
        pw.productId = newproduct.id;
        pw.PricebookEntryId = pbeTest.id;
        pw.productName = newproduct.Name;
        pw.listPrice = pbeTest.unitprice;

        List<ProductWrapper> pwList = new List<ProductWrapper>();
        pwList.add(pw);


        Test.startTest();
        List<orderAvalaibleProducts.ProductWrapper> result = orderAvalaibleProducts.getOrderAvalaibleProducts(standard.Id);
        Test.stopTest();

        System.assert(result.size() < 1, 'Error');


                    
    }

}
