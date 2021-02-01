@istest
public with sharing class orderProducts_test {
    
    class testData {
        Order order;
        Pricebook2 standard;
        PricebookEntry pbeTest;
        List<Product2> Products = new List<Product2>();
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        List<orderProducts.OrderProductWrapper> wrapper1 = new List<orderProducts.OrderProductWrapper>();
        List<orderProducts.ProductWrapper> wrapper2 = new List<orderProducts.ProductWrapper>();
                
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

            order = new Order(
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


            pbeTest = new PricebookEntry();
            pbeTest.pricebook2Id = standard.id;
            pbeTest.product2id = newproduct2.id;
            pbeTest.unitprice = 1500.0;
            pbeTest.isactive = true;  
            insert pbeTest;
            

            OrderItem OrderItems = new OrderItem();
            OrderItems.OrderId = order.id;
            OrderItems.PricebookEntryId = pbeTest.id;
            OrderItems.ListPrice = pbeTest.unitprice;
            OrderItems.UnitPrice = pbeTest.unitprice;
            OrderItems.Quantity = 1;
            OrderItems.Product2Id = newproduct2.id; 
            insert OrderItems;

            orderProducts.OrderProductWrapper opw = new orderProducts.OrderProductWrapper();
            opw.productId = newproduct2.id;
            opw.productName = newproduct2.Name;
            opw.listPrice = OrderItems.listPrice;
            opw.Quantity = OrderItems.Quantity;
            opw.totalPrice = OrderItems.totalPrice;
            wrapper1.add(opw);

            for(Product2 prod : Products)
            {

                orderProducts.ProductWrapper pw = new orderProducts.ProductWrapper();
                pw.productId = prod.id;
                pw.PricebookEntryId = pbeTest.id;
                pw.productName = prod.Name;
                pw.listPrice = pbeTest.unitprice;
                wrapper2.add(pw);

            }

        }
    }

    static testMethod void getOrderOrderProducts_test() {
        Test.startTest();
        testData data = new testData();
        List<orderProducts.OrderProductWrapper> result = orderProducts.getOrderOrderProducts(data.order.id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'result: ' + result);
    }

    static testMethod void UpdateOrderProducts_test() {
        Test.startTest();
        testData data = new testData();
        List<orderProducts.OrderProductWrapper> result = orderProducts.UpdateOrderProducts(data.wrapper1, data.wrapper2, data.order.id );
        Test.stopTest();

        System.assertEquals(result.size() , 3, 'result: ' + result);
    }
}