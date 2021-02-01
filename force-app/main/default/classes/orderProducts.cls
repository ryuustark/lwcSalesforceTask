public with sharing class orderProducts {
    

    @AuraEnabled(cacheable=true)
    public static List<OrderProductWrapper> getOrderOrderProducts(id orderId) {
        List<OrderItem> listOI = [SELECT Product2.id,Product2.Name, ListPrice, Quantity, TotalPrice
                            FROM OrderItem
                            WHERE OrderId =: orderId //8014x0000004N79AAE
                            ORDER BY id];
                            
        List<OrderProductWrapper> OrderProducs = new List<OrderProductWrapper>();

        for(OrderItem currOI : listOI){
            OrderProductWrapper wrapper = new OrderProductWrapper();
            wrapper.productName = currOI.Product2.Name;
            wrapper.productId = currOI.Product2.Id;
            wrapper.listPrice = currOI.ListPrice;
            wrapper.Quantity = currOI.Quantity;
            wrapper.totalPrice = currOI.TotalPrice;
            OrderProducs.add(wrapper);
        }            

        return OrderProducs;
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderProductWrapper> UpdateOrderProducts(List<OrderProductWrapper> OPw,List<ProductWrapper> productsToInsert, id OrderId) {
        Map<Id,OrderProductWrapper> OrderProducs = new Map<Id,OrderProductWrapper>();
        Map<id, Decimal> productids = new Map<id, Decimal>(); 
        id parentOrderId = OrderId;
        Boolean sendList = false;

        for(OrderProductWrapper tempOrderProduct : OPw)
        {
            OrderProducs.put(tempOrderProduct.productId,tempOrderProduct);
        }       
        //System.debug('>>> OrderProducs: ' + OrderProducs);
        //System.debug('>>> productsToInsert: ' + productsToInsert);

        //Get list of ProductIds from Query
        for( ProductWrapper tempProductWrapper : productsToInsert){
            productIds.put(tempProductWrapper.productId, tempProductWrapper.listPrice);
            //System.debug('>>> productIds: ' + tempProductWrapper);
        }        
        //System.debug('>>> productIds: ' + productIds);

        Map<id,OrderItem> orderItems = new Map<ID, OrderItem>([SELECT Id, ListPrice, Quantity, TotalPrice, Product2.id, Product2.Name, PricebookEntryId, OrderId  
                                    FROM OrderItem
                                    WHERE Product2.id =:productIds.keyset()]); 
        List<OrderItem> oderstoAdd = orderItems.values();
        //System.debug('>>> orderItems: ' + orderItems);
        //go through Product List and current Order Products
        
        System.debug('>>> Products ' + productsToInsert);
        for(ProductWrapper Product : productsToInsert)
        {
            id currentPricebookEntryId = Product.PricebookEntryId;
            Boolean ProdExist = false;
            id tempProductId = Product.productId;
            OrderProductWrapper exProduct = new OrderProductWrapper();
            OrderProductWrapper newProduct = new OrderProductWrapper();
            OrderItem newOI = new Orderitem();

            System.debug('>>> Product ' + Product);
            for(OrderProductWrapper existingProducts : OrderProducs.values())
            {
                System.debug('>>> existingProducts ' + existingProducts);
                if(Product.productId == existingProducts.productId)
                {
                    ProdExist = true;
                    exProduct = existingProducts;
                }
            }

            if(ProdExist)
                {                
                    System.debug('>>> Product Exist');
                    exProduct.Quantity ++;        
                    exProduct.totalPrice = exProduct.Quantity * exProduct.ListPrice;
                    //System.debug('>>> orderItems to modify: ' + exProduct);
                    //OrderProducs.put(tempProductId,exProduct);
                    OrderProducs.put(tempProductId,exProduct);
                }else {                
                    sendList = true;
                    System.debug('>>> Product NOT Exist RUUUUUUUUUUUUUM');
                    newProduct.productName = Product.productName;
                    newProduct.productId = tempProductId;
                    newProduct.listPrice = Product.listPrice;
                    newProduct.Quantity = 1;
                    newProduct.totalPrice = Product.listPrice;
                    OrderProducs.put(tempProductId,newProduct);

                    
                    newOI.OrderId = parentOrderId;
                    newOI.ListPrice = newProduct.listPrice;
                    newOI.UnitPrice = newProduct.listPrice;
                    newOI.Quantity = newProduct.Quantity;
                    newOI.Product2Id = newProduct.productId;
                    newOI.PricebookEntryId = currentPricebookEntryId;

                    oderstoAdd.add(newOI);
                }


        }
        if(!sendList){
            System.enqueueJob( new AsyncOrderInsert(orderItems));
        } else {
            System.enqueueJob( new AsyncOrderInsert(oderstoAdd));

        }
        return OrderProducs.values();
    }

    public class OrderProductWrapper {
        @AuraEnabled public String productName{get;set;}
        @AuraEnabled public Id productId{get;set;}
        @AuraEnabled public Decimal listPrice{get;set;}
        @AuraEnabled public Decimal Quantity{get;set;}
        @AuraEnabled public Decimal totalPrice{get;set;}
    }

    public class ProductWrapper {
        @AuraEnabled public String productName{get;set;}
        @AuraEnabled public Id productId{get;set;}
        @AuraEnabled public Decimal listPrice{get;set;}
        @AuraEnabled public Id PricebookEntryId{get;set;}

    }
    
    public class AsyncOrderInsert implements Queueable {
        private List<OrderItem> OIListUpserted = new List<OrderItem>();
        private List<OrderItem> OIList = new List<OrderItem>();

        public AsyncOrderInsert(Map<Id, OrderItem> OIMap) {
            this.OIList = OIMap.values();
        }

        public AsyncOrderInsert(List<OrderItem> OI) {
            this.OIList = OI;
        }

        public void execute(QueueableContext context) {
            if(this.OIList.size() > 50)
            {
                for(integer i=0;i< 50; i++)
                {
                    OIListUpserted.add(OIList[i]);
                    OIList.remove(i);
                }
                System.enqueueJob( new AsyncOrderInsert(OIList));

            }
            else {
                OIListUpserted = OIList.clone();
            }

            System.debug('>>> OI Updated: ' + OIListUpserted);
            upsert OIListUpserted;        


        }
    }

}