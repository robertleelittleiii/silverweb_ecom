/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


retailer_edit_dialog = "";

function retailereditClickBinding(selector) {
    // selectors .edit-retailer-item, tr.retailer-row 

    $(selector).unbind("click").one("click", function (event) {
        event.stopPropagation();
        console.log($(this).find('#retailer-id').text());
        var retailer_id = $(this).parent().find('#item-id').text();
        if (retailer_id === "")
        {
            var retailer_id = $(this).find('#retailer-id').text();

        }
        
        var url = '/retailers/' + retailer_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        // $(this).effect("highlight", {color: "#669966"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                retailer_edit_dialog = createAppDialog(data, "edit-retailer-dialog", {}, "");
                retailer_edit_dialog.dialog({
                    close: function (event, ui) {
                        if ($("table#retailer-table").length > 0)
                            retailerTable.draw();

                        if ($("div#edit-retailer-dialog").length > 0)
                        {
                            current_retailer_id = $("div#retailer div#attr-retailers div#retailer-id").text();
                            if (retailer_id === current_retailer_id)
                            {
                                show_retailer(retailer_id);
                            }
                        }

                        if (typeof tinyMCE.editors[0] != "undefined")
                        {
                            tinyMCE.editors[0].destroy();
                        }

                        $('div#edit-retailer-dialog').html("");
                        $('div#edit-retailer-dialog').dialog("destroy");
                        update_content();
                        update_backoffice_elements();
                        retailereditClickBinding(selector);
                        retailereditClickBinding("div.edit-retailer");

                    }
                });

                require("retailers/edit.js");
                requireCss("retailers/edit.css");
                requireCss("retailers.css");

                retailers_edit_callDocumentReady();
                retailer_edit_dialog.dialog('open');


            }
        });

    });
}

