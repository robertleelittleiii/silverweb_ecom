var couponTableAjax;
var coupons_index_callDocumentReady_called = false;

$(document).ready(function () {
    if (!coupons_index_callDocumentReady_called)
    {
        coupons_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        } else
        {
            coupons_index_callDocumentReady();
        }
    }
});

//function bindClicktoCouponTableRow(){
//    $('#coupon-table .coupon-row').on("click",function(e){
//        console.log(e.target);
//        if (!($(e.target).prop("class") == "delete-image"))
//        {
//            $(this).addClass('row_selected');
//            couponID=$(this).find("#coupon-id").text();
//            window.location = "/coupons/edit/"+couponID;
//        }
//    });
//}

function coupons_index_callDocumentReady() {
    requireCss("tables.css");
    requireCss("coupons.css");
    require("coupons/shared.js");

    $("body").css("cursor", "progress");

    createCouponsTable();

    $("body").css("cursor", "default");

    bindNewCoupon();

    $("a.button-link").button();

    bindDeleteCoupon();

    $(".best_in_place").best_in_place();

}

function bindDeleteCoupon() {
    $(".delete-coupon-item").on("click", function (e) {

        console.log($(this).parent().parent().parent().find('#coupon-id').text());
        var coupon_id = $(this).parent().parent().parent().find('#coupon-id').text();
        deleteCoupon(coupon_id);
        return false;
    });
}

function deleteCoupon(coupon_id)
{
    var answer = confirm('Are you sure you want to delete this?')
    if (answer) {
        $.ajax({
            url: '/coupons/delete_ajax?id=' + coupon_id,
            success: function (data)
            {
                setUpPurrNotifier("Notice", "Item Successfully Deleted.");
                couponTableAjax.draw();

            }
        });

    }
}

function createCouponsTable() {
    couponTableAjax = $('#coupon-table').DataTable({
        pageLength: 25,
        lengthMenu: [[25, 50, 100], [25, 50, 100]],
        stateSave: true,
        stateDuration: 0,
        stateSaveCallback: function (settings, data) {
            localStorage.setItem('DataTables_coupon_' + window.location.pathname, JSON.stringify(data));
        },
        stateLoadCallback: function (settings) {
            return JSON.parse(localStorage.getItem('DataTables_coupon_' + window.location.pathname));
        },
        processing: true,
        order: [[0, "asc"]],
        serverSide: true,
        searchDelay: 500,
        ajax: {
            url: "/coupons/coupon_table",
            type: "post"
        },
        rowCallback: function (row, data, index) {
            $(row).addClass('coupon-row');
            $(row).addClass('gradeA');
            //return row;
        },
        initComplete: function () {
            // $(".best_in_place").best_in_place(); 

        },
        drawCallback: function (settings) {

            couponeditClickBinding("tr.coupon-row");
            bindDeleteCoupon();

            image_list = $('a.zoom-image');
            if (image_list.length > 0) {
                image_list.imgPreview();
            }
            $("td.dataTables_empty").attr("colspan", "20")

        },
        columns: [
            {width: '100'},
            {width: '600'},
            {width: '75'},
            {width: '75'},
            {width: '25'},
            {width: '25'}
        ]
//        ,"iDisplayLength": 25,
//        "aLengthMenu": [[25, 50, 100], [25, 50, 100]],
//        "bStateSave": true,
//        "bProcessing": true,
//        "bServerSide": true,
//        "sAjaxSource": "/coupons/coupon_table",
//        "fnRowCallback": function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {
//            $(nRow).addClass('coupon-row');
//            $(nRow).addClass('gradeA');
//            
//            return nRow;
//        },
//        
//        "aoColumns": 
//        [ 
//        {
//            "sWidth": "100"
//        },
//        {
//            "sWidth": "600"
//        },
//        {
//            "sWidth": "75"
//        },
//        {
//            "sWidth": "75"
//        },
//        {
//            "sWidth": "25"
//        },
//        {
//            "sWidth": "25"
//        }
//        ]
//        ,
//        "fnDrawCallback": function (){
//            couponeditClickBinding("tr.coupon-row");
//            bindDeleteCoupon();
//
//            image_list = $('a.zoom-image');
//            if(image_list.length > 0){
//            image_list.imgPreview();
//            }
//        }
    });

    $("#coupon-table").css("width", "100%")


}

function bindNewCoupon() {

    $('a#new-coupon').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        // editCoupon(data.id);

        couponTableAjax.draw();
        setUpPurrNotifier("Notice", "New Coupon Created!'");
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Coupon Creation Failed!'");
    });

//    $('a#new-coupon').bind('ajax:beforeSend', function (evt, xhr, settings) {
//        // alert("ajax:before");  
//        console.log('ajax:before');
//        console.log(evt);
//        console.log(xhr);
//        console.log(settings);
//
//        $("body").css("cursor", "progress");
//
//
//
//    }).bind('ajax:success', function (evt, data, status, xhr) {
//        //  alert("ajax:success"); 
//        console.log('ajax:success');
//        console.log(evt);
//        console.log("date:" + data + ":");
//
//        $("body").css("cursor", "progress");
//        console.log(data.id);
//        editCoupon(data.id);
//
//        console.log(status);
//        console.log(xhr);
//
//    }).bind('ajax:error', function (evt, xhr, status, error) {
//        // alert("ajax:failure"); 
//        console.log('ajax:error');
//        console.log(evt);
//        console.log(xhr);
//        console.log(status);
//        console.log(error);
//
//        alert("Error:" + JSON.parse(data.responseText)["error"]);
//        $("body").css("cursor", "default");
//
//
//    }).bind('ajax:complete', function (evt, xhr, status) {
//        //    alert("ajax:complete");  
//        console.log('ajax:complete');
//        console.log(evt);
//        console.log(xhr);
//        // console.log(status);
//        $("body").css("cursor", "default");
//
//
//    });

}


function bindPreferences() {

    $('a#coupon-prefs').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        couponPrefsDialog = createAppDialog(data, "coupon-prefs-dialog");
        couponPrefsDialog.dialog('open');
        couponPrefsDialog.dialog({
            close: function (event, ui) {
                couponPrefsDialog.html("");
                couponPrefsDialog.dialog("destroy");
            }
        });
        require("coupons/coupon_preferences.js");
        coupon_preferences_callDocumentReady();

        //update_rolls_callDocumentReady();


        // setupRolesSelection();
        // 
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Prefs could not be opened!'");
    });


}


