/*

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component displayname="Order Item" entityname="SlatwallOrderItem" table="SlatwallOrderItem" persistent="true" accessors="true" output="false" extends="BaseEntity" {
	
	// Persistent Properties
	property name="orderItemID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="price" ormtype="big_decimal";
	property name="quantity" ormtype="integer";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID" constrained="false";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID" constrained="false";
	
	// Related Object Properties
	property name="order" cfc="Order" fieldtype="many-to-one" fkcolumn="orderID";
	property name="sku" cfc="Sku" fieldtype="many-to-one" fkcolumn="skuID";
	property name="orderFulfillment" cfc="OrderFulfillment" fieldtype="many-to-one" fkcolumn="orderFulfillmentID";
	property name="orderDeliveryItems" singularname="orderDeliveryItem" cfc="OrderDeliveryItem" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true" cascade="all";
	property name="orderItemStatusType" cfc="Type" fieldtype="many-to-one" fkcolumn="orderItemStatusTypeID";
	property name="attributeValues" singularname="attributeValue" cfc="OrderItemAttributeValue" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true" cascade="all-delete-orphan";
	property name="appliedTaxes" singularname="appliedTax" cfc="OrderItemAppliedTax" fieldtype="one-to-many" fkcolumn="orderItemID" inverse="true" cascade="all-delete-orphan";
	
	public any function init() {
		
		// set status to new by default
		if( !structKeyExists(variables,"orderItemStatusType") ) {
			var statusType = getService("orderService").getTypeBySystemCode("oistNew");
			setOrderItemStatusType(statusType);
		}
		// set default collections for association management methods
		if(isNull(variables.orderDeliveryItems)) {
		   variables.orderDeliveryItems = [];
		}
		if(isNull(variables.attributeValues)) {
		   variables.attributeValues = [];
		}
		if(isNull(variables.appliedTaxes)) {
		   variables.appliedTaxes = [];
		}
		
		return super.init();
	}
	
	public string function getStatus(){
		return getOrderItemStatusType().getType();
	}
	
	public string function getStatusCode() {
		return getOrderItemStatusType().getSystemCode();
	}
	
	public numeric function getExtendedPrice() {
		return getPrice()*getQuantity();
	}
	
	public numeric function getTaxAmount() {
		if(!structKeyExists(variables,"taxAmount")) {
			variables.taxAmount = 0;
			if(!isNull(getAppliedTaxes())) {
				for(var i=1; i<=arrayLen(getAppliedTaxes()); i++) {
					variables.taxAmount += getAppliedTaxes()[i].getTaxAmount();
				}	
			}
		}
		return variables.taxAmount;
	}
	
	public numeric function getQuantityDelivered() {
		if(!structKeyExists(variables,"quantityDelivered") || !isNumeric(variables.quantityDelivered)) {
			variables.quantityDelivered = 0;
			var deliveryItems = getOrderDeliveryItems();
			for( var thisDeliveryItem in deliveryItems ) {
				variables.quantityDelivered += thisDeliveryItem.getQuantityDelivered();				
			}			
		}
		return variables.quantityDelivered;
	}
	
	public numeric function getQuantityUndelivered() {
		return getQuantity() - getQuantityDelivered();
	}
	
	public string function displayCustomizations(format="list") {
		var customizations = "";
		if(arguments.format == 'htmlList' && this.hasAttributeValue()) {
			customizations = "<ul>";
		}
		for(var i=1; i<=arrayLen(getAttributeValues()); i++) {
			if(len(customizations) && arguments.format == "list") {
				customizations &= ", ";
			} else if(arguments.format == "htmlList") {
				customizations &= "<li>";
			}
			customizations &= "#getAttributeValues()[i].getAttribute().getAttributeName()#: #getAttributeValues()[i].getAttributeValue()#";
			if(arguments.format == "htmlList") {
				customizations &= "</li>";
			}
		}
		if(arguments.format == "htmlList") {
			customizations &= "</ul>";
		}		
		return customizations;
	}
	
	/******* Association management methods for bidirectional relationships **************/
	
	// Order (many-to-one)
	
	public void function setOrder(required Order Order) {
		variables.order = arguments.order;
		if(isNew() || !arguments.order.hasOrderItem(this)) {
			arrayAppend(arguments.order.getOrderItems(),this);
		}
	}
	
	public void function removeOrder(Order order) {
		if(!structKeyExists(arguments, "order")) {
			arguments.order = variables.order;
		}
		var index = arrayFind(arguments.order.getOrderItems(),this);
		if(index > 0) {
			arrayDeleteAt(arguments.order.getOrderItems(),index);
		}    
		structDelete(variables,"order");
		
		// Remove from order fulfillment to trigger those actions
		removeOrderFulfillment();
    }
    
    // Order Fulfillment (many-to-one)
    
    public void function setOrderFulfillment(required OrderFulfillment orderFulfillment) {
		variables.orderFulfillment = arguments.orderFulfillment;
		if(isNew() || !arguments.orderFulfillment.hasOrderFulfillmentItems(this)) {
			arrayAppend(arguments.orderFulfillment.getOrderFulfillmentItems(),this);
		}
		
		// Run Item's Changed Function
		variables.orderFulfillment.orderFulfillmentItemsChanged();
    }
    
    public void function removeOrderFulfillment(OrderFulfillment orderFulfillment) {
    	if(!structKeyExists(arguments, "orderFulfillment")) {
    		arguments.orderFulfillment = variables.orderFulfillment;
    	}
    	var index = arrayFind(arguments.orderFulfillment.getOrderFulfillmentItems(), this);
    	if(index > 0) {
    		arrayDeleteAt(arguments.orderFulfillment.getOrderFulfillmentItems(), index);
    	}
    	
    	// Run Item's Changed Function
		variables.orderFulfillment.orderFulfillmentItemsChanged();
		
    	structDelete(variables, "orderFulfillment");
    }
    
    // Order Delivery Item (one-to-many)
    
    public void function addOrderDeliveryItem(required OrderDeliveryItem orderDeliveryItem) {
    	arguments.orderDeliveryItem.setOrderItem(this);
    }
    
    public void function removeOrderDeliveryItem(required OrderDeliveryItem orderDeliveryItem) {
    	arguments.orderDeliveryItem.removeOrderItem(this);
    }
    
     // Attribute Values (one-to-many)
    
    public void function addAttributeValue(required OrderItemAttributeValue attributeValue) {
    	arguments.attributeValue.setOrderItem(this);
    }
    
    public void function removeAttributeValue(required OrderItemAttributeValue attributeValue) {
    	arguments.attributeValue.removeOrderItem(this);
    }
    
    // Applied Taxes (one-to-many)
    
	public void function addAppliedTax(required OrderItemAppliedTax orderItemAppliedTax) {
    	arguments.orderItemAppliedTax.setOrderItem(this);
    }
    
    public void function removeAppliedTax(required OrderItemAppliedTax orderItemAppliedTax) {
    	arguments.orderItemAppliedTax.removeOrderItem(this);
    }
    
	/************   END Association Management Methods   *******************/
	
	public any function getActionOptions() {
		var smartList = getService("orderService").getOrderItemStatusActionSmartList();
		smartList.addFilter("orderItemStatusType_typeID", getOrderItemStatusType().getTypeID());
		return smartList.getRecords();
	}
}
