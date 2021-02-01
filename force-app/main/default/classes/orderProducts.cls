public with sharing class orderProducts {
    

    @AuraEnabled(cacheable=true)
    public static List<OrderProductWrapper> getOrderOrderProducts(id orderId) {
        //Get Products already added to the Order
        List<OrderItem> listOI = [SELECT Product2.id,Product2.Name, ListPrice, Quantity, TotalPrice
                            FROM OrderItem
                            WHERE OrderId =: orderId //8014x0000004N79AAE
                            ORDER BY id];
                            
        List<OrderProductWrapper> OrderProducs = new List<OrderProductWrapper>();
        //Handle Products to show in the table
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
        //Get the products in the Order and the list of products that will be added
        Map<Id,OrderProductWrapper> OrderProducs = new Map<Id,OrderProductWrapper>();
        Map<id, Decimal> productids = new Map<id, Decimal>(); 
        id parentOrderId = OrderId;
        Boolean sendList = false;

        //convert into Map to handle by Product id
        for(OrderProductWrapper tempOrderProduct : OPw)
        {
            OrderProducs.put(tempOrderProduct.productId,tempOrderProduct);
        }

        //Get list of ProductIds from Query
        //convert into Map to handle by Product id
        for( ProductWrapper tempProductWrapper : productsToInsert){
            productIds.put(tempProductWrapper.productId, tempProductWrapper.listPrice);
        }        

        //Get OrderItem related to the Order
        Map<id,OrderItem> orderItems = new Map<ID, OrderItem>([SELECT Id, ListPrice, Quantity, TotalPrice, Product2.id, Product2.Name, PricebookEntryId, OrderId  
                                    FROM OrderItem
                                    WHERE Product2.id =:productIds.keyset()]); 
        List<OrderItem> oderstoAdd = orderItems.values();

        //go through Product that will be added List and current Order Products
        for(ProductWrapper Product : productsToInsert)
        {
            id currentPricebookEntryId = Product.PricebookEntryId;
            Boolean ProdExist = false;
            id tempProductId = Product.productId;
            OrderProductWrapper exProduct = new OrderProductWrapper();
            OrderProductWrapper newProduct = new OrderProductWrapper();
            OrderItem newOI = new Orderitem();

            //Verify if the Product already exist on the order
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
                    //if Product exist, update it from OrderItem 
                    for(OrderItem tempOI : orderitems.values())
                    {
                        if(tempOI.Product2Id == tempProductId)
                        {
                            newOI = tempOI;
                        }

                    }

                    //increase Quantity
                    exProduct.Quantity ++;        
                    exProduct.totalPrice = exProduct.Quantity * exProduct.ListPrice;
                    newOI.Quantity ++;
                    OrderProducs.put(tempProductId,exProduct);
                    orderitems.put(newOI.id,newOI);
                }else {                
                    //Need to Add a new Product
                    sendList = true;
                    newProduct.productName = Product.productName;
                    newProduct.productId = tempProductId;
                    newProduct.listPrice = Product.listPrice;
                    newProduct.Quantity = 1;
                    newProduct.totalPrice = Product.listPrice;
                    OrderProducs.put(tempProductId,newProduct);

                    //create the OrderItem to insert
                    newOI.OrderId = parentOrderId;
                    newOI.ListPrice = newProduct.listPrice;
                    newOI.UnitPrice = newProduct.listPrice;
                    newOI.Quantity = newProduct.Quantity;
                    newOI.Product2Id = newProduct.productId;
                    newOI.PricebookEntryId = currentPricebookEntryId;

                    oderstoAdd.add(newOI);
                }


        }
        //Handle upsert of OrderItems in Queubable Apex
        if(!sendList){
            System.enqueueJob( new AsyncOrderInsert(orderItems));
        } else {
            System.enqueueJob( new AsyncOrderInsert(oderstoAdd));

        }
        //return the new list with correct Quantity
        return OrderProducs.values();
    }

      
    public class AsyncOrderInsert implements Queueable {
        private List<OrderItem> OIListUpserted = new List<OrderItem>();
        private List<OrderItem> OIList = new List<OrderItem>();

        public AsyncOrderInsert(Map<Id, OrderItem> OIMap) {
            //convert map into List to handle 
            this.OIList = OIMap.values();
        }

        public AsyncOrderInsert(List<OrderItem> OI) {
            this.OIList = OI;
        }

        public void execute(QueueableContext context) {
            //handle by packs of 50 in case there are more than 50 products added at the same time
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
                //there are less than 50 products
                OIListUpserted = OIList.clone();
            }

            upsert OIListUpserted;        


        }
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

}