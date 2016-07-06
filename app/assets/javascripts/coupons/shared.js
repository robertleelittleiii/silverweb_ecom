/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


coupon_edit_dialog = "";

function couponeditClickBinding(selector) {
    // selectors .edit-coupon-item, tr.coupon-row 

    $(selector).unbind("click").one("click", function (event) {
        event.stopPropagation();
        console.log($(this).find('#coupon-id').text());
        var coupon_id = $(this).parent().find('#item-id').text();
        if (coupon_id === "")
        {
            var coupon_id = $(this).find('#coupon-id').text();
            
        }
        var is_iframe = $("application-space").length > 0

        var url = '/coupons/' + coupon_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        // $(this).effect("highlight", {color: "#669966"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                coupon_edit_dialog = createAppDialog(data, "edit-coupon-dialog", {}, "");
                coupon_edit_dialog.dialog({
                    close: function (event, ui) {
                        if ($("table#coupon-table").length > 0)
                            couponTableAjax.draw();
                        
                        if ($("div#edit-coupon-dialog").length > 0)
                        {
                         current_coupon_id = $("div#coupon div#attr-coupons div#coupon-id").text();
                            if (coupon_id === current_coupon_id)
                            {
                                show_coupon(coupon_id);
                            }
                        }
                        
                        if(typeof tinyMCE.editors[0] != "undefined")
                        {
                            tinyMCE.editors[0].destroy();
                        }
                        
                        $('div#edit-coupon-dialog').html("");
                        $('div#edit-coupon-dialog').dialog("destroy");
                        update_content();
                        couponeditClickBinding(selector);

                    }
                });
                
                require("coupons/edit.js");
                requireCss("coupons/edit.css");
                requireCss("coupons.css");

                coupons_edit_callDocumentReady();
                coupon_edit_dialog.dialog('open');


            }
        });




//        if (is_iframe) {
//                        $('iframe#coupons-app-id',window.parent.document).attr("src",url);
//                        couponeditClickBinding(this);
//        }
//        else
//            {
//                window.location = url;
//
//            }

    });
}
