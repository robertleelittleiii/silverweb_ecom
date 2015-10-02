/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function bindCopyAddressClick() {
    $("#copy-to-billing").click(function(){
        $("#order_bill_first_name").val($("#order_ship_first_name").val());
        $("#order_bill_last_name").val($("#order_ship_last_name").val());
        $("#order_bill_street_1").val($("#order_ship_street_1").val());
        $("#order_bill_street_2").val($("#order_ship_street_2").val());
        $("#order_bill_city").val($("#order_ship_city").val());
        $("#order_bill_state").val($("#order_ship_state").val());
        $("#order_bill_zip").val($("#order_ship_zip").val());
    });   
}


$(document).ready(function(){
    bindCopyAddressClick();
   
});