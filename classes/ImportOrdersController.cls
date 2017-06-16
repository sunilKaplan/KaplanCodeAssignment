public class ImportOrdersController {
   
public Blob csvFileBody{get;set;}
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}

public Boolean isUploaded {
      get { if (isUploaded == null) {  isUploaded = false; } return isUploaded; }
      set;
}

public Boolean isSaved {
      get { if (isSaved == null) {  isSaved = false; } return isSaved; }
      set;
}
    
public OrdersDAO dao;    
    
public List<SVOrderDetail__c> lOrderDetails{get;set;}
public List<String> lOrdersCreated{get;set;} 
public List<String> lOrdersFailed{get;set;} 
    
  public ImportOrdersController(){
    csvFileLines = new String[]{};
    lOrderDetails = new List<SVOrderDetail__c>();
    lOrdersCreated = new List<String>();
    lOrdersFailed =  new List<String>(); 
    dao = OrdersDAO.getDAOInstance(); // gets singleton instance  
  }
  
  public void importCSVFile() {
       try{
           reset();
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           List<OrderDetailBean> lOrdDetailBeans = new List<OrderDetailBean>(); 
           for(Integer i=1;i<csvFileLines.size();i++){               
               SVOrderDetail__c orderObj = new SVOrderDetail__c();
               string[] csvRecordData = csvFileLines[i].split(',');
               
               OrderDetailBean myBean = new OrderDetailBean(
                                               csvRecordData[1],
                                               csvRecordData[0],
                                               csvRecordData[4],
                                               Integer.valueOf(csvRecordData[2]),
                                               Double.valueOf(csvRecordData[3]),
                                               DateTime.valueOf(csvRecordData[5])
                                              );
               lOrdDetailBeans.add(myBean);
           }
        //insert lOrderDetails;
        lOrderDetails.clear();
        lOrderDetails.addAll(dao.storeCSVOrderDetails(lOrdDetailBeans));   
        
        isUploaded = true;   
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure input csv file is valid!');
            ApexPages.addMessage(errorMessage);
        }  
  }
    
  public void createOrders() {
       System.debug('SV: In createOrders()'); 
       Set<String> sInputSKUs = new Set<String>();
       // Creating map of <orderId,List of OrderItemDetailBeans>
       Map<String, List<OrderDetailBean>>  mOrders = new Map<String, List<OrderDetailBean>>();
        for (SVOrderDetail__c dtl : lOrderDetails) {
            sInputSKUs.add(dtl.product_sku__c);
            OrderDetailBean myBean = new OrderDetailBean(
                                               dtl.order_item_id__c,
                                               dtl.Order_Id__c,
                                               dtl.product_sku__c,
                                               Integer.valueOf(dtl.sold_quantity__c),
                                               Double.valueOf(dtl.Unit_Price__c),
                                               dtl.Order_Create_Date__c
                                              );
            // if map has orderId with empty list of beans
            if (mOrders.get(dtl.order_id__c) == null) {
               List<OrderDetailBean> newList = new List<OrderDetailBean>();
               newList.add(myBean); 
               mOrders.put(dtl.order_id__c, newList) ;
            } else {
               List<OrderDetailBean> existingList = mOrders.get(dtl.order_id__c);
               existingList.add(myBean);
               mOrders.put(dtl.order_id__c, existingList) ; 
            }
        }
        reset(); 
        Set<String> ordersCreated = dao.storeOrders(mOrders, sInputSKUs);
        //lOrdersCreated.clear();
        lOrdersCreated.addAll(ordersCreated);
        
        Set<String> ordersFailed  = new Set<String>();
        for (String key : mOrders.keySet()) {
            if (!ordersCreated.contains(key)) {
               ordersFailed.add(key); 
            }  
        }
        //lOrdersFailed.clear();
        lOrdersFailed.addAll(ordersFailed);
        isSaved = true;
    }
    
    public void reset() {
       //csvFileBody=null; 
       lOrderDetails.clear();
       lOrdersCreated.clear();
       lOrdersFailed.clear();
    }
}