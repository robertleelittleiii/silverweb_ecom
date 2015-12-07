
var coupons_edit_callDocumentReady_called = false;

$(document).ready(function () {
    if (!coupons_edit_callDocumentReady_called)
    {
        coupons_edit_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            coupons_edit_callDocumentReady();
        }
    }
});

function coupons_edit_callDocumentReady() {
    $("#coupon-tabs").tabs({
        activate: function (event, ui) {
            if ($(ui.newTab[0]).find('a').text() == "Preview")
            {
                console.log("updated!")

                $('iframe.preview').each(function () {
                    this.contentWindow.location.reload(true)
                });
            }

        }
    });

    
    $(".best_in_place").best_in_place();
    activate_buttons();
    ui_ajax_select();
 }



function activate_buttons() {

    $("div.ui-button a").button();
    $("a.button-link").button();

}

function BestInPlaceCallBack(input) {
    //    if(input.data.indexOf("coupon_detail[color]") != -1)
    if (input.attributeName.indexOf("color") != -1)
    {
    }
};

