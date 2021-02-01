@isTest //(SeeAllData = true)
public with sharing class orderAvalaibleProducts_test {
    
    public class ProductWrapper {
        @AuraEnabled public String productName{get;set;}
        @AuraEnabled public Id productId{get;set;}
        @AuraEnabled public Decimal listPrice{get;set;}
        @AuraEnabled public Id PricebookEntryId{get;set;}
    }

    class testData {
        Pricebook2 standard;
        Order order;
        List<Product2> Products = new List<Product2>();
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        List<ProductWrapper> wrapper1 = new List<ProductWrapper>();
        List<ProductWrapper> wrapper2 = new List<ProductWrapper>();
                
        testData()
        {
            Contact contact1 = new Contact(
                FirstName = 'test contact',
                LastName = 'Dummy'
                );
            insert contact1;
            
            Account acc = new Account(
                Name='Test1');          
            insert acc;

            Contract contract = new Contract(
                AccountId = acc.id);
            insert contract;

            standard = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true);        
            update standard;

            Order order = new Order(
                AccountId = acc.id,
                ContractId = contract.id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Pricebook2Id = standard.id
                 );
            insert order;

            Product2 newproduct =new Product2();
            newproduct.Name='test';
            newproduct.productCode='1111';
            newproduct.isActive = true;
            Products.add(newproduct);

            Product2 newproduct2 =new Product2();
            newproduct2.Name='test2';
            newproduct2.productCode='2222';
            newproduct2.isActive = true;
            Products.add(newproduct2);
            
            Product2 newproduct3 =new Product2();
            newproduct3.Name='test3';
            newproduct3.productCode='3333';
            newproduct3.isActive = true;
            Products.add(newproduct3);

            insert Products;

            for(Product2 prod : Products)
            {

                PricebookEntry pbeTest = new PricebookEntry();
                pbeTest.pricebook2Id = standard.id;
                pbeTest.product2id = prod.id;
                pbeTest.unitprice = 1500.0;
                pbeTest.isactive = true;
                PricebookEntryList.add(pbeTest);     

                
                ProductWrapper pw = new ProductWrapper();
                pw.productId = prod.id;
                pw.PricebookEntryId = pbeTest.id;
                pw.productName = prod.Name;
                pw.listPrice = pbeTest.unitprice;
                wrapper1.add(pw);

            }
            insert PricebookEntryList;
            

        }
    }

    static testMethod void testAvalaibleProducts() {
        
        Test.startTest();
        testData data = new testData();
        List<orderAvalaibleProducts.ProductWrapper> result = orderAvalaibleProducts.getOrderAvalaibleProducts(data.standard.Id);
        Test.stopTest();

        System.assertEquals(result.size() , 3, 'result: ' + result);


                    
    }

}