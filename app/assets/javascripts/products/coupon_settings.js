/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var product_coupons_settings_callDocumentReady_called = false;

$(document).ready(function () {
    if (!product_coupons_settings_callDocumentReady_called)
    {
        product_coupons_settings_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            product_coupons_settings_callDocumentReady();
        }
    }
});

function product_coupons_settings_callDocumentReady() {
    
}