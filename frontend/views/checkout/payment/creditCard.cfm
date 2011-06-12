<!---

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

--->

<cfset local.sameAsShipping = false>
<cfif arrayLen($.slatwall.cart().getOrderFulfillments()) eq 1 and not isNull($.slatwall.cart().getOrderFulfillments()[1].getShippingAddress())>
	<cfset local.sameAsShipping = true />
	<cfset local.address = $.slatwall.cart().getOrderFulfillments()[1].getShippingAddress() />
<cfelse>
	<cfset local.address = getBeanFactory().getBean("addressBean").newAddress() />
</cfif>

<cfoutput>
	<div class="svocheckoutpaymentcreditcard">
		<div id="checkoutPaymentContent" class="contentBlock">
			<div class="paymentAddress">
				<h4>Billing Address</h4>
				<cfif local.sameAsShipping>
					<dl>
						<dt>Same As Shipping</dt>
						<dd><input type="hidden" name="sameAsShipping" value="" /><input type="checkbox" name="sameAsShipping" value="1" checked="checked" /></dd>
					</dl>
					<cf_SlatwallAddressDisplay address="#local.address#" edit="true">
				<cfelse>
					<cf_SlatwallAddressDisplay address="#local.address#" edit="true">
				</cfif>
			</div>
			<div class="paymentMethod">
				<h4>Payment Method</h4>
				<dl>
					<dt>Name On Card</dt>
					<dd><input type="text" name="nameOnCart" /></dd>
					<dt>Credit Card Number</dt>
					<dd><input type="text" name="creditCardNumber" /></dd>
					<dt>CVV Code</dt>
					<dd><input type="text" name="securityCode" /></dd>
					<dt>Expires</dt>
					<dd>
						<select name="expirationMonth">
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
						</select> / 
						<select name="expirationYear">
							<option value="01">2011</option>
							<option value="02">2012</option>
							<option value="03">2013</option>
							<option value="04">2014</option>
							<option value="05">2015</option>
							<option value="06">2016</option>
							<option value="07">2017</option>
							<option value="08">2018</option>
							<option value="09">2019</option>
							<option value="10">2020</option>
							<option value="11">2021</option>
							<option value="12">2022</option>
						</select>
					</dd>
				</dl>
			</div>
		</div>
		<input type="hidden" name="paymentMethodID" value="creditCard" />
		<script type="text/javascript">
			jQuery(document).ready(function(){
				
				jQuery('input[name="sameAsShipping"]').click(function(){
					var shippingAddress = {
						name : '#local.address.getName()#',
						company : '#local.address.getCompany()#',
						streetAddress :  '#local.address.getStreetAddress()#',
						street2Address : '#local.address.getStreet2Address()#',
						city : '#local.address.getCity()#',
						stateCode : '#local.address.getStateCode()#',
						postalCode : '#local.address.getPostalCode()#',
						countryCode : '#local.address.getCountryCode()#',
					};
					if(jQuery(this).is(':checked')){
						jQuery('input[name="name"]').val(shippingAddress['name']);
						jQuery('input[name="company"]').val(shippingAddress['company']);
						jQuery('input[name="streetAddress"]').val(shippingAddress['streetAddress']);
						jQuery('input[name="street2Address"]').val(shippingAddress['street2Address']);
						jQuery('input[name="city"]').val(shippingAddress['city']);
						jQuery('input[name="postalCode"]').val(shippingAddress['postalCode']);
						jQuery('input[name="stateCode"]').val(shippingAddress['stateCode']);
						jQuery('select[name="stateCode"]').val(shippingAddress['stateCode']);
						jQuery('select[name="countryCode"]').val(shippingAddress['countryCode']);
					} else {
						jQuery('input[name="name"]').val('');
						jQuery('input[name="company"]').val('');
						jQuery('input[name="streetAddress"]').val('');
						jQuery('input[name="street2Address"]').val('');
						jQuery('input[name="city"]').val('');
						jQuery('input[name="postalCode"]').val('');
						jQuery('input[name="stateCode"]').val('');
						jQuery('select[name="stateCode"]').val('');
					};
				});
			});
		</script>
	</div>
</cfoutput>