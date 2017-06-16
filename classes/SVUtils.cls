public with sharing class SVUtils {

    public static Map<String, ID> getProductSKUIds (Set<String> sInputSKUs) {
        
      System.debug('SV: SVUtils::getProductSKUIds sInputSKUs-' + sInputSKUs);  
      Map<String, ID> skuMap = new Map<String, ID>();
        
      Set<SVProduct__c> products = new Set<SVProduct__c>([Select Id, SKU__c 
                                                          From SVProduct__c where SKU__c in :sInputSKUs]);
                                                          
      for (SVProduct__c product : products) {
         skuMap.put(product.SKU__c, product.id);                                                     
      }
      
      System.debug('SV: SVUtils::getProductSKUIds skuMap-' + skuMap);  
      return skuMap;       
    }
}