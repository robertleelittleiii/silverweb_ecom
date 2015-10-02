/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var menus_show_products_type_callDocumentReady_called = false;


$(document).ready(function () {
    if (!menus_show_products_type_callDocumentReady_called)
    {
        menus_show_products_type_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            menus_show_products_type_callDocumentReady();
        }
    }
});

function menus_show_products_type_callDocumentReady() {
    
   // alert("loaded!.");
    setupCheckboxes(".department-check");
    bind_department_check();
    render_category_div();
};


function bind_department_check() {

    $('.department-check').change(function () {

        render_category_div();


    });

}

function render_category_div() {
    var menu_id = $("#current-menu-id").text();

    $.ajax({
        url: '/menus/render_category_div',
        data: {"id": menu_id},
        method: "get",
        dataType: "html",
        success: function (data) {
            $('#category-div').html(data)
            setupCheckboxes(".category-check");

        }
    });
}