public class InventoryDAO {
    
    private static InventoryDAO myDAOSingletonInstance = null;
    
    private InventoryDAO() {
        // Do nothing .. just to stop instatiation
    } 
    
    public static InventoryDAO getDAOInstance() {
        if (myDAOSingletonInstance == null) {
            myDAOSingletonInstance = new InventoryDAO();
        }    
        return myDAOSingletonInstance;
    }
    
    public List<SVProduct__c> getAllProducts() {
       List<SVProduct__c> lProducts = [Select 
                        Name__c
                      , Quantity__c
                      , SKU__c
                      , Unit_Price__c
                      , isActive__c               
                      FROM SVProduct__c
                      //where isActive__c = true
                      order by Name__c asc
                      LIMIT 200 // to adhere to sfdc governor limits
                     ];
 
        return lProducts;
    }
    
    public SVProduct__c addProduct(String pSKU, 
                           String pName,
                           String pQty,
                           String pUnitPrice) {
        SVProduct__c myNewProduct;                              
        try {                     
            myNewProduct = new SVProduct__c();  
            myNewProduct.SKU__c =  pSKU;
            myNewProduct.Name__c =   pName;
            myNewProduct.Quantity__c =  Integer.valueOf(pQty);
            myNewProduct.Unit_Price__c =  Double.valueOf(pUnitPrice);
            myNewProduct.isActive__c = true;
            
            insert myNewProduct;
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while adding product.');
            ApexPages.addMessage(errorMessage);
            return null;                   
        }
        return myNewProduct;
    }
    
   
    public boolean saveEdits(List<SVProduct__c> lProducts) {
        try {
            update lProducts;
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while editing product(s).');
            ApexPages.addMessage(errorMessage);
            return false;
        }  
        return true;
    }
    
    public List<SVProduct__c> searchProducts(String pName, String pSKU) {
        List<SVProduct__c> results = new List<SVProduct__c>();
        try {
            String soql = 'SELECT Name__c, Quantity__c, SKU__c, Unit_Price__c, isActive__c FROM SVProduct__c Where id != null';
           if (pName != null && pName.length() > 0)
            soql += ' and Name__c LIKE \'%'+String.escapeSingleQuotes(pName)+'%\'';
           if (pSKU != null && pSKU.length() > 0)
            soql += ' and SKU__c LIKE \'%'+String.escapeSingleQuotes(pSKU)+'%\''; 
            
           results = Database.query(soql + ' order by Name__c asc Limit 500 ');
          
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while searching product(s).');
            ApexPages.addMessage(errorMessage);            
        } 
         return results;
    }
    
}