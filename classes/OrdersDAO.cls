public class OrdersDAO {

    private static OrdersDAO myDAOSingletonInstance = null;
    
    private OrdersDAO() {
        // Do nothing .. just to stop instatiation
    } 
    
    public static OrdersDAO getDAOInstance() {
        if (myDAOSingletonInstance == null) {
            myDAOSingletonInstance = new OrdersDAO();
        }    
        return myDAOSingletonInstance;
    }
    
    // store csv uploads for future historical reference. 
    // we can purge this SVOrderDetail__c table on regular basis
    public List<SVOrderDetail__c> storeCSVOrderDetails(List<OrderDetailBean> lOrderDetls) {
       List<SVOrderDetail__c> lItems = new List<SVOrderDetail__c>();
       try {
            for (OrderDetailBean dtlBean : lOrderDetls) {
               SVOrderDetail__c item = new SVOrderDetail__c() ;
               item.Order_Item_Id__c   =  dtlBean.orderItemId;
               item.order_id__c     =  dtlBean.orderId;
               item.Product_SKU__c     =  dtlBean.productSKU;
               item.Sold_Quantity__c   =  dtlBean.soldQty;
               item.Unit_Price__c      =  dtlBean.unitPrice;    
               item.Order_Create_Date__c = dtlBean.orderCreateDate;
                
               lItems.add(item); 
            }
           upsert lItems; 
       } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while inserting SVOrderDetail__c.');
            ApexPages.addMessage(errorMessage);
        }   
       return  lItems;
    }
    
    public Set<String> storeOrders( Map<String, List<OrderDetailBean>> mOrders, 
                                    Set<String> sInputSKUs) {
        String errors;
        List<SV_Order__c> lOrders = new List<SV_Order__c>();
        List<SV_Order_Item__c> lOrderItems = new List<SV_Order_Item__c>();
        
        Map<String, ID> skuMap = SVUtils.getProductSKUIds(sInputSKUs);
                                        
        Map<String,ID> mOrdersCreated = new Map<String,ID>();
        try {
            for (String orderId : mOrders.keySet()) {
                if (orderId != null && mOrders.get(orderId) != null) {
                    // get all order items
                    List<OrderDetailBean> lOrderDetailBeans = mOrders.get(orderId); 
                    List<SV_Order_Item__c> items = getOrderItems(lOrderDetailBeans, skuMap);
                    
                    // get Order                
                    SV_Order__c myOrder = new SV_Order__c();
                    myOrder.Order_Id__c = orderId;
                    myOrder.order_create_date__c = lOrderDetailBeans[0].orderCreateDate;
                    
                    lOrders.add(myOrder);
                    lOrderItems.addAll(items);
                }
            }
                    
            // Store Orders to DB 
            Set<ID> ordersCreatedSet = new Set<ID>();
            List<SV_Order__c> lOrdersCreated = new List<SV_Order__c>();
            Database.SaveResult[] ordersSR = Database.insert(lOrders, false);
            for (Database.SaveResult sr : ordersSR) {
              if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                   errors = errors + err.getMessage(); 
                }
              }
              if (sr.isSuccess()) {
                 System.debug('SV: Successfully inserted Order. ID: ' + sr.getId()); 
                 ordersCreatedSet.add(sr.getId());
               }  
            }
            system.debug('SV: storeOrders errors -' + errors);
            
            // Now get the successfully inserted order ids and link them to order item object
            // to maintain master detail relationship

            lOrdersCreated = [select id, Order_Id__c 
                                                FROM SV_Order__c where id in :ordersCreatedSet];
            
            
            for (SV_Order__c ord : lOrdersCreated) {
               mOrdersCreated.put(ord.Order_Id__c, ord.id) ;
            }
            System.debug('SV: OrdersDAO:: storeOrders mOrdersCreated - ' + mOrdersCreated);
            
            // assign order master ids to order child items
            for (SV_Order_Item__c item : lOrderItems) {
                if (mOrdersCreated.get(item.SV_Order_Id__c) != null)
                  item.SV_Order__c = mOrdersCreated.get(item.SV_Order_Id__c);
            }
                
            Database.SaveResult[] orderItemsSR = Database.insert(lOrderItems, false);
            
            
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while creating orders.');
            ApexPages.addMessage(errorMessage);
            
        } 
        
        System.debug('SV: OrdersDAO:: mOrdersCreated - ' + mOrdersCreated.keySet());
        return mOrdersCreated.keySet();
    }
    
    // helper method to convert beans to custom order item objects
    public List<SV_Order_Item__c> getOrderItems(List<OrderDetailBean> lOrderDetailBeans,
                                                Map<String, ID> skuMap) {
        List<SV_Order_Item__c> lItems = new List<SV_Order_Item__c>();
        for (OrderDetailBean dtlBean : lOrderDetailBeans) {
           SV_Order_Item__c item = new SV_Order_Item__c() ;
           item.Order_Item_Id__c   =  dtlBean.orderItemId;
           item.SV_Order_Id__c     =  dtlBean.orderId;
           item.Product_SKU__c     =  dtlBean.productSKU;
           item.Sold_Quantity__c   =  dtlBean.soldQty;
           item.Unit_Price__c      =  dtlBean.unitPrice;    
           if (skuMap.get(dtlBean.productSKU) != null)
             item.Product_SKU_Id__c = skuMap.get(dtlBean.productSKU); // if none mapped, its a bad item              
            
           lItems.add(item); 
        }
       return lItems;
    }
    
}