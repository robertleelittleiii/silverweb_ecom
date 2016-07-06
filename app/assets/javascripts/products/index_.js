var productTableAjax;
var products_index_callDocumentReady_called = false;

$(document).ready(function () {
    if (!products_index_callDocumentReady_called)
    {
        products_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        } else
        {
            products_index_callDocumentReady();
        }
    }
});

//function bindClicktoProductTableRow(){
//    $('#product-table .product-row').on("click",function(e){
//        console.log(e.target);
//        if (!($(e.target).prop("class") == "delete-image"))
//        {
//            $(this).addClass('row_selected');
//            productID=$(this).find("#product-id").text();
//            window.location = "/products/edit/"+productID;
//        }
//    });
//}

function products_index_callDocumentReady() {
    require("imgpreview.full.jquery.js");
    requireCss("tables.css");
    requireCss("products.css");
    require("products/shared.js");
    require("imgpreview.full.jquery.js");

    $("body").css("cursor", "progress");

    createProductsTable();

    $("body").css("cursor", "default");

    bindNewProduct();

    $("a.button-link").button();

    bindDeleteProduct();

    bindPreferences();

    bindCoupons();
}

function bindDeleteProduct() {
    $(".delete-product-item").on("click", function (e) {

        console.log($(this).parent().parent().parent().find('#product-id').text());
        var product_id = $(this).parent().parent().parent().find('#product-id').text();
        deleteProduct(product_id);
        return false;
    });
}

function deleteProduct(product_id)
{
    var answer = confirm('Are you sure you want to delete this?')
    if (answer) {
        $.ajax({
            url: '/products/delete_ajax?id=' + product_id,
            success: function (data)
            {
                setUpPurrNotifier("Notice", "Item Successfully Deleted.");
                productTableAjax.draw();

            }
        });

    }
}

function createProductsTable() {
    productTableAjax = $('#product-table').DataTable({
        pageLength: 25,
        lengthMenu: [[25, 50, 100], [25, 50, 100]],
        stateSave: true,
        stateDuration: 0,
        stateSaveCallback: function (settings, data) {
            localStorage.setItem('DataTables_products_' + window.location.pathname, JSON.stringify(data));
        },
        stateLoadCallback: function (settings) {
            return JSON.parse(localStorage.getItem('DataTables_products_' + window.location.pathname));
        },
        processing: true,
        order: [[0, "asc"]],
        serverSide: true,
        searchDelay: 500,
        ajax: {
            url: "/products/product_table",
            type: "post"
        },
        rowCallback: function (row, data, index) {
            $(row).addClass('product-row');
            $(row).addClass('gradeA');
            //return row;
        },
        initComplete: function () {
            // $(".best_in_place").best_in_place(); 

        },
        drawCallback: function (settings) {
            producteditClickBinding("tr.product-row");
            bindDeleteProduct();

            image_list = $('a.zoom-image');
            if (image_list.length > 0) {
                image_list.imgPreview();
            }
            //bindClicktoProductTableRow();
            $("td.dataTables_empty").attr("colspan", "20")
        }
        ,
        columns: [
            {width: '100'},
            {width: '300'},
            {width: '600'},
            {width: '25'},
            {width: '25'}
        ]
//        ,
//        "iDisplayLength": 25,
//        "aLengthMenu": [[25, 50, 100], [25, 50, 100]],
//        "bStateSave": true,
//        "bProcessing": true,
//        "bServerSide": true,
//        "sAjaxSource": "/products/product_table",
//        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
//            $(nRow).addClass('product-row');
//            $(nRow).addClass('gradeA');
//
//            return nRow;
//        },
//        "aoColumns":
//                [
//                    {
//                        "sWidth": "100"
//                    },
//                    {
//                        "sWidth": "300"
//                    },
//                    {
//                        "sWidth": "600"
//                    },
//                    {
//                        "sWidth": "25"
//                    },
//                    {
//                        "sWidth": "25"
//                    }
//                ]
//        ,
//        "fnDrawCallback": function () {
//            producteditClickBinding("tr.product-row");
//            bindDeleteProduct();
//
//            image_list = $('a.zoom-image');
//            if (image_list.length > 0) {
//                image_list.imgPreview();
//            }
//        }
    });

    $("#product-table").css("width", "100%")


}

function bindNewProduct() {

    $('a#new-product').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        productTableAjax.draw();
        setUpPurrNotifier("Notice", "New Product Created!'");
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Product Creation Failed!'");
    });

//    $('a#new-product').bind('ajax:beforeSend', function (evt, xhr, settings) {
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
//        editProduct(data.id);
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

    $('a#product-prefs').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        productPrefsDialog = createAppDialog(data, "product-prefs-dialog");
        productPrefsDialog.dialog('open');
        productPrefsDialog.dialog({
            close: function (event, ui) {
                productPrefsDialog.html("");
                productPrefsDialog.dialog("destroy");
            }
        });
        require("products/product_preferences.js");
        product_preferences_callDocumentReady();

        //update_rolls_callDocumentReady();


        // setupRolesSelection();
        // 
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Prefs could not be opened!'");
    });


}

function bindCoupons() {

    $('a#coupons-settings').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        productPrefsDialog = createAppDialog(data, "coupons-settings-dialog");
        productPrefsDialog.dialog('open');
        productPrefsDialog.dialog({
            close: function (event, ui) {
                productPrefsDialog.html("");
                productPrefsDialog.dialog("destroy");
            }
        });
        require("coupons/index_.js");
        coupons_index_callDocumentReady();

        //update_rolls_callDocumentReady();


        // setupRolesSelection();
        // 
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Coupons could not be opened!'");
    });


}

