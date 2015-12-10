
var orderTableAjax = "";
var orders_index_callDocumentReady_called = false;

$(document).ready(function () {
    if (!orders_index_callDocumentReady_called)
    {
        orders_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            orders_index_callDocumentReady();
        }
    }
});


function orders_index_callDocumentReady() {
    requireCss("tables.css");

    $("body").css("cursor", "progress");

    createOrderTable();

    $("body").css("cursor", "default");

    $("a.button-link").button();

}



function emailOrder(order_id)
{
    var answer = confirm('Are you sure you want to resend this invoice?')
    if (answer) {
        $.ajax({
            url: '/orders/resend_invoice?order_id=' + order_id,
            success: function (data)
            {
                setUpPurrNotifier("Notice", "Invoice Successfully Resent.");
                orderTableAjax.fnDraw();

            }
        });

    }
}



function viewOrderDialog() {

    $('#edit-order-dialog').dialog({
        autoOpen: false,
        width: 455,
        height: 625,
        modal: true,
        buttons: {
            "Delete": function () {
                order_id = $(".m-content div#order-id").text().trim();
                if (confirm("Are you sure you want to delete this order?"))

                {
                    $(this).dialog("close");

                    $.ajax({
                        url: '/orders/delete_ajax?id=' + order_id,
                        success: function (data)
                        {
                            orderTableAjax.fnDraw();
                        }
                    });
                }
                else
                {

                }
            },
            "Ok": function () {
                $(this).dialog("close");
                orderTableAjax.fnDraw();
            }
        }

    });
}



function createOrderTable() {
    console.log("create table");
    orderTableAjax = $('#order-table').dataTable({
        "iDisplayLength": 25,
        "aLengthMenu": [[25, 50, 100], [25, 50, 100]],
        "bStateSave": true,
        "fnStateSave": function (oSettings, oData) {
            localStorage.setItem('DataTables_orders_' + window.location.pathname, JSON.stringify(oData));
        },
        "fnStateLoad": function (oSettings) {
            return JSON.parse(localStorage.getItem('DataTables_orders_' + window.location.pathname));
        },
        "bProcessing": true,
        "bServerSide": true,
        "aaSorting": [[1, "asc"]],
        "sAjaxSource": "/orders/order_table",
        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
            $(nRow).addClass('order-row');
            $(nRow).addClass('gradeA');
            return nRow;
        },
        "fnInitComplete": function () {
            // $(".best_in_place").best_in_place(); 

        },
        "fnDrawCallback": function () {
            $(".best_in_place").best_in_place();
            //ordereditClickBinding(".edit-order-item");
            bindEmailOrder();
            bindViewOrder();
//bindDeleteOrder();
        }
    });
}


function bindEmailOrder() {
    $(".email-order-item").off("click").on("click", function (e) {

        console.log($(this).parent().parent().parent().find('#order-id').text());
        var order_id = $(this).parent().parent().parent().find('#order-id').text();
        emailOrder(order_id);
        return false;
    });
}

function bindViewOrder() {
    $(".view-order-item").off("click").on("click", function (e) {

        // console.log($(this).parent().parent().parent().find('#order-id').text());
        var order_id = $(this).parent().parent().parent().find('#order-id').text();
        orderviewClickBinding(order_id);
        return false;
    });
}


function orderviewClickBinding(order_id) {

    var url = '/orders/show?id=' + order_id + '&request_type=window&window_type=iframe&as_window=true';

    // $(this).effect("highlight", {color: "#669966"}, 1000);

    $.ajax({
        url: url,
        success: function (data)
        {
            order_edit_dialog = createAppDialog(data, "edit-order", {}, "");
            order_edit_dialog.dialog({
                close: function (event, ui) {
                    $('#edit-order').html("");
                    $('#edit-order').dialog("destroy");
                }
            });

        }
    });


}
;

