var retailerTable;
var retailers_index_callDocumentReady_called = false;
$(document).ready(function () {
    if (!retailers_index_callDocumentReady_called)
    {
        retailers_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
//  alert("it is a window");
        } else
        {
            retailers_index_callDocumentReady();
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

function bindClicktoRetailerTableRow() {
    $('#retailer-table .retailer-row').on("click", function (e) {
        console.log(e.target);
        if (!($(e.target).prop("class") == "delete-image"))
        {
            $(this).addClass('row_selected');
            retailerID = $(this).find("#retailer-id").text().strip();
            window.location = "/retailers/edit/" + retailerID;
        }
    });
}

function retailers_index_callDocumentReady() {
    require("imgpreview.full.jquery.js");
    require("retailers/shared.js");

    $("a.button-link").button();

    bindNewRetailer();
    bindDeleteRetailer();
    
    $("#loader_progress").show();

    retailerTable = $('#retailer-table').DataTable({
        retailerLength: 25,
        lengthMenu: [[25, 50, 100], [25, 50, 100]],
        stateSave: true,
        stateDuration: 0,
        stateSaveCallback: function (settings, data) {
            localStorage.setItem('DataTables_retailers_' + window.location.pathname, JSON.stringify(data));
        },
        stateLoadCallback: function (settings) {
            return JSON.parse(localStorage.getItem('DataTables_retailers_' + window.location.pathname));
        },
        processing: true,
        order: [[0, "asc"]],
        serverSide: true,
        searchDelay: 500,
        ajax: {
            url: "/retailers/retailer_table",
            type: "post"
        },
        rowCallback: function (row, data, index) {
            $(row).addClass('retailer-row');
            $(row).addClass('gradeA');
            //return row;
        },
        initComplete: function () {
            // $(".best_in_place").best_in_place(); 

        },
        drawCallback: function (settings) {
            retailereditClickBinding("tr.retailer-row")
//            bindClicktoRetailerTableRow("tr.retailer-row");
            $(".best_in_place").best_in_place();

//            image_list = $('a.zoom-image');
//            if (image_list.length > 0) {
//                image_list.imgPreview();
//            }
            //bindClicktoProductTableRow();
            $("td.dataTables_empty").attr("colspan", "20")
        }
//        ,
//        columns: [
//            {width: '100'},
//            {width: '300'},
//            {width: '600'},
//            {width: '25'},
//            {width: '25'}
//        ]
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
//    $("#product-table").css("width", "100%")
//
//
//    retailerTableAjax = $('#retailer-table').dataTable({
//       "iDisplayLength": 25,
//        "aLengthMenu": [[25, 50, 100], [25, 50, 100]],
//        "bStateSave": true,
//        "bProcessing": true,
//        "bServerSide": true,
//        "sAjaxSource": "/retailers/retailer_table",
//        "fnRowCallback": function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {
//            $(nRow).addClass('retailer-row');
//            $(nRow).addClass('gradeA');
//            
//            return nRow;
//        },
//        
//       
//        "fnDrawCallback": function (){
//            bindClicktoProductTableRow();
//            image_list = $('a.zoom-image');
//            if(image_list.length > 0){
//            image_list.imgPreview();
//            }
//        }
//    });
//    
    $("#retailer-table").css("width", "100%")

    $("#loader_progress").hide();




//    $('#delete-retailer-item').live('ajax:success', function(xhr, data, status){
//        $("#loader_progress").show();
//        theTarget=this.parentNode.parentNode;
//        var aPos = retailerTableAjax.fnGetPosition( theTarget );
//        retailerTableAjax.fnDeleteRow(aPos) ;
//        $("#loader_progress").hide();
//    });


}


function bindNewRetailer() {

    $('a#new-retailer').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        retailerTable.draw();
        setUpPurrNotifier("Notice", "New Retailer Created!'");
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Retailer Creation Failed!'");
    });
//    $('a#new-retailer').bind('ajax:beforeSend', function (evt, xhr, settings) {
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
//        editRetailer(data.id);
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
function bindDeleteRetailer() {
    $(".delete-retailer-item").on("click", function (e) {

// console.log($(this).parent().parent().parent().find('#retailer-id').text());
        var retailer_id = $(this).parent().parent().parent().find('#retailer-id').text();
        deleteRetailer(retailer_id);
        return false;
    });
}