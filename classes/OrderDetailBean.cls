public class OrderDetailBean {

        public String orderItemId {get; set;}
        public String orderId {get; set;}
        public String productSKU {get; set;}
        public Integer soldQty {get; set;}
        public Double unitPrice {get; set;}
        public DateTime orderCreateDate {get; set;}
        
        public OrderDetailBean(String orderItemId, 
                              String orderId,
                              String productSKU, 
                              Integer soldQty, 
                              Double unitPrice,
                              DateTime orderCreateDate) {
           this.orderItemId= orderItemId;
           this.orderId= orderId;
           this.productSKU = productSKU;
           this.soldQty = soldQty;
           this.unitPrice = unitPrice;
           this.orderCreateDate = orderCreateDate;                            
  }  
}