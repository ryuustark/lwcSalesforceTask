public with sharing class orderAvalaibleProducts {

    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getOrderAvalaibleProducts(id PBId) {
        List<PricebookEntry> listPE = [SELECT Product2.id, Product2.Name, UnitPrice, id
        FROM PricebookEntry
        WHERE IsActive = true AND PricebookEntry.Pricebook2Id =:PBId //01s4x0000072qiLAAQ
        ORDER BY Name];
                            
        List<ProductWrapper> OrderProducs = new List<ProductWrapper>();
        System.debug('>> listPE: ' + listPE);
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