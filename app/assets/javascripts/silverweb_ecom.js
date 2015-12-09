/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


$(document).ready(function () {
    
    enableProductEdit();
    
    });
    
    
    function enableProductEdit() {
    if ($("div.edit-product").length > 0)
    {
        require("products/shared.js");
        producteditClickBinding("div.edit-product");
    }
}

function ui_ajax_cart_select() {

    $("select.ui-ajax-cart-select").bind("change", function () {
        selected_item = $(this).val();
        controller = this.getAttribute("data-path")

        //alert(this.getAttribute("data-id"));


        $.ajax({
            url: controller, // controller + "/update",
            dataType: "json",
            type: "PUT",
            data: "id=" + this.getAttribute("data-id") + "&cart[" + this.getAttribute("name") + "=" + selected_item,
            success: function (data)
            {
                // alert(data);
                if (data === undefined || data === null || data === "")
                {
                    //display warning
                }
                else
                {

                }
            }
        });
    });
}