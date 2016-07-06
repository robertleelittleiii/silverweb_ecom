/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


product_edit_dialog = "";

function producteditClickBinding(selector) {
    // selectors .edit-product-item, tr.product-row 

    $(selector).unbind("click").one("click", function (event) {
        event.stopPropagation();
        console.log($(this).find('#product-id').text());
        var product_id = $(this).parent().find('#item-id').text();
        if (product_id === "")
        {
            var product_id = $(this).find('#product-id').text();
            
        }
        var is_iframe = $("application-space").length > 0

        var url = '/products/' + product_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        // $(this).effect("highlight", {color: "#669966"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                product_edit_dialog = createAppDialog(data, "edit-product-dialog", {}, "");
                product_edit_dialog.dialog({
                    close: function (event, ui) {
                        if ($("table#product-table").length > 0)
                            productTableAjax.draw();
                        
                        if ($("div#edit-product-dialog").length > 0)
                        {
                         current_product_id = $("div#product div#attr-products div#product-id").text();
                            if (product_id === current_product_id)
                            {
                                show_product(product_id);
                            }
                        }
                        
                        if(typeof tinyMCE.editors[0] != "undefined")
                        {
                            tinyMCE.editors[0].destroy();
                        }
                        
                        $('div#edit-product-dialog').html("");
                        $('div#edit-product-dialog').dialog("destroy");
                        update_content();
                        producteditClickBinding(selector);
                        producteditClickBinding("div.edit-product");

                    }
                });
                
                require("products/edit.js");
                requireCss("products/edit.css");
                requireCss("products.css");

                products_edit_callDocumentReady();
                product_edit_dialog.dialog('open');


            }
        });




//        if (is_iframe) {
//                        $('iframe#products-app-id',window.parent.document).attr("src",url);
//                        producteditClickBinding(this);
//        }
//        else
//            {
//                window.location = url;
//
//            }

    });
}
