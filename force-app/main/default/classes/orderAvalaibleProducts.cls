public with sharing class orderAvalaibleProducts {

    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getOrderAvalaibleProducts(id PBId) {
        //Get products from pricebookEntry that are active in the order pricebook
        List<PricebookEntry> listPE = [SELECT Product2.id, Product2.Name, UnitPrice, id
        FROM PricebookEntry
        WHERE IsActive = true AND PricebookEntry.Pricebook2Id =:PBId 
        ORDER BY Name];
                            
        List<ProductWrapper> OrderProducs = new List<ProductWrapper>();
        //Set the data in ProductWrapper to show in table and sent it to the Component 2
        for(PricebookEntry currPE : listPE){
            ProductWrapper wrapper = new ProductWrapper();
            wrapper.productName = currPE.Product2.Name;
            wrapper.productId = currPE.Product2.Id;
            wrapper.listPrice = currPE.UnitPrice;
            wrapper.PricebookEntryId = currPE.Id;            
            //System.debug('>>> currPE: ' + currPE);

            OrderProducs.add(wrapper);
        }            

        return OrderProducs;
    }

    public class ProductWrapper {
        @AuraEnabled public String productName{get;set;}
        @AuraEnabled public Id productId{get;set;}
        @AuraEnabled public Decimal listPrice{get;set;}
        @AuraEnabled public Id PricebookEntryId{get;set;}
    }
    
}