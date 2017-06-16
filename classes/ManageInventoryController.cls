public class ManageInventoryController {
    
    public List<SVProduct__c> lProducts {get;set;} 
    public List<SVProduct__c> lProductsBk {get;set;}
    
    public InventoryDAO dao;
    
    public String pSearchByName {get;set;} 
    public String pSearchBySKU {get;set;}
    public String pFilterByName {get;set;} 
    public String pFilterBySKU {get;set;} 
    
    public String msgAddProduct {get;set;}
    public String msgFilters {get;set;}
    
    /*public class ProductProtoType {
        public Integer sku {get; set;}
        public String name {get; set;}
        public Integer qty {get; set;}
        public Double unitPrice {get; set;}
        
        public ProductProtoType(Integer sku, String name, Integer qty, Double unitPrice) {
           this.sku = sku;
           this.name= name;
           this.qty = qty;
           this.unitPrice = unitPrice;
        }
    }*/
    
    public Boolean isAddWindowOn {
      get { if (isAddWindowOn == null) {  isAddWindowOn = false; } return isAddWindowOn; }
      set;
    }
        
    public ManageInventoryController() {
        if (lProducts == null)
          lProducts = new List<SVProduct__c>();
        if (lProductsBk == null)
          lProductsBk = new List<SVProduct__c>();
        dao = InventoryDAO.getDAOInstance(); // gets singleton instance
        //loadExistingProducts();
    }
    
    public void loadExistingProducts() {
        
       List<SVProduct__c> lAllProducts = dao.getAllProducts();        
       
        lProducts.clear();
        lProductsBk.clear();
        lProducts.addAll(lAllProducts);
        lProductsBk.addAll(lProducts);
    }
    
    public void closeAddPopup () {              
        isAddWindowOn = false;
    }         
        
    public void showAddPopUp () {
        isAddWindowOn = true;        
    }
    
    public pageReference addNewProduct() {
        String pQty           = ApexPages.currentPage().getParameters().get('pQty');
        String pName          = ApexPages.currentPage().getParameters().get('pName');
        String pSKU           = ApexPages.currentPage().getParameters().get('pSKU');
        String pUnitPrice     = ApexPages.currentPage().getParameters().get('pUnitPrice');
        
        System.debug('SV: pName-'+pName);
        System.debug('SV: pSKU-'+pSKU);
        
        SVProduct__c newProduct = dao.addProduct(pSKU, pName, pQty, pUnitPrice);
        
        if (newProduct != null)          
            msgAddProduct = 'New Product Added!';
        else
            msgAddProduct='' ;
        
        System.debug('SV: msgAddProduct-'+msgAddProduct);
        
        //loadExistingProducts();
        lProducts.add(newProduct);
        
        closeAddPopup();
        return null;        
    }
    
    public void saveEdits() {
        dao.saveEdits(lProducts);
    }
    
    public pageReference runSearch() {
        List<SVProduct__c> searchResults = dao.searchProducts(pSearchByName, pSearchBySKU);
        lProducts.clear();        
        lProducts.addAll(searchResults);        
        lProductsBk.clear();        
        lProductsBk.addAll(searchResults);
        System.debug('SV: runSearch:: lProducts size-'+lProducts.size());
        return null;
    }
    
    public void resetFilters() {
        //isFilterOn = false;
        lProducts.clear();        
        lProducts.addAll(lProductsBk);
        pFilterByName='';
        pFilterBySKU='';
    }   
    
    public void searchByFilters () {
        try{
        lProducts.clear();        
        lProducts.addAll(lProductsBk);                 
        System.debug('SV: lProducts before' + lProducts.size());
        System.debug('SV: lProductsBk before' + lProductsBk.size());
            
        List<SVProduct__c> filteredObjs = new List<SVProduct__c>();
        for ( SVProduct__c obj : lProducts) {
            if ((String.isBlank(pFilterByName) || (!String.isBlank(pFilterByName) && !String.isBlank(obj.Name__c) 
                       && obj.Name__c.containsIgnoreCase(pFilterByName)))
                && (String.isBlank(pFilterBySKU) || (!String.isBlank(pFilterBySKU) && !String.isBlank(obj.SKU__c) 
                       && obj.SKU__c.containsIgnoreCase(pFilterBySKU)))) {
              
                filteredObjs.add(obj);
              } 
        }            
        
        if (filteredObjs.size() > 0) {    
               lProducts.clear();        
               lProducts.addAll(filteredObjs);                                 
        } else {
            msgFilters = 'No matches found!';
        } 
           
        System.debug('SV: searchByFilters::  filteredObjs' + filteredObjs);
         System.debug('SV: searchByFilters:: lProducts after' + lProducts.size());
        System.debug('SV: searchByFilters:: lProductsBk after' + lProductsBk.size());            
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
          System.debug('SV: searchByFilters:: e.getMessage()' + e.getMessage());  
       }    
    }

}