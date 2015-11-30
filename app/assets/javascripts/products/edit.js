var productDetailsTable;
var vendorTable;

var product_detail_id = "";
var product_detail_list_row = "";

var products_edit_callDocumentReady_called = false;

var tinyMCE_editor_product = "";

$(document).ready(function () {
    if (!products_edit_callDocumentReady_called)
    {
        products_edit_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            products_edit_callDocumentReady();
        }
    }
});

function products_edit_callDocumentReady() {    
    $("#product-tabs").tabs({
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
    
    require("jquery-ui-combobox.js");
    requireCss("jquery-ui-combobox.css");

    requireCss("image_libraries/image_list.css");


    setupCheckboxes(".department-check");
    setupCheckboxes(".category-check");

    bindProductDetailNew();
    buildproductDetailsListTable();
    //   bindBlurToDepartmentPopup();
    bindDivDepartmentUpdate();
    $(".combobox").combobox();
    bindChangeColor();
    tinyMCE_editor_product = tinyMCE.init(tinymce_config);
    $(".best_in_place").best_in_place();
    set_up_save_callback();


    bind_file_upload_to_upload_form();
    bindImageChage();
    bind_download_to_files();
    bindPicturesSort();
    bindDeleteImage();
    bind_mouseover();
    activate_buttons();
    initialize_edit_button();
    $("a.button-link").button();

// test();
}



var toggleLoading = function () {
    $("#loader_progress").toggle()
};
var toggleAddButton = function () {
    $("#upload-form").toggle()
};

function bindImageChage() {

    //
    //
    // image class bindings
    //

    $('input#image').bind("change", function () {
        //alert("changed");
        toggleLoading();
        toggleAddButton();
        $(this).closest("form").trigger("submit");
        $(".imageSingle .best_in_place").best_in_place();
        disableSelectOptionsSeperators();

    });

}

function updateBestinplaceImageTitles() {
    $(".imageSingle .best_in_place").best_in_place();

}

function updateImages() {

    //  alert("color changed");
    var $product_id = $("#product-id").text();
    $("body").css("cursor", "progress");
// $("#loader_progress").show();

    $.post('/products/render_image_section/' + $product_id, function (data)
    {
        $('.imagesection').html(data);
        $("body").css("cursor", "default");

        // $("#loader_progress").hide();
        styleizefilebutton();
        bindImageChage();
        disableSelectOptionsSeperators();

    });

}

function bind_file_upload_to_upload_form()
{
    $("form.upload-form").fileupload({
        dataType: "json",
        add: function (e, data) {
            file = data.files[0];
            data.context = $(tmpl("template-upload", file));
            // $("div.progress").progressbar();
            $('#images').fadeIn();
            $('#images').prepend(data.context);
            var jqXHR = data.submit()
                    .success(function (result, statusText, jqXHR) {

                        // console.log("------ - fileupload: Success - -------");
                        // console.log(result);
                        // console.log(statusText);
                        // console.log(jqXHR);

                        // console.log(JSON.stringify(jqXHR.responseJSON["attachment"]));

                        // console.log(typeof(jqXHR.responseText));
// specifically for IE8. 
                        if (typeof (jqXHR.responseText) == "undefined") {
                            setUpPurrNotifier("info.png", "Notice", jqXHR.responseJSON["attachment"][0]);
                            data.context.remove();
                        }
                        else
                        {
                            render_picture(result.id);
                        }

                    })
                    .error(function (jqXHR, statusText, errorThrown) {
                        console.log("------ - fileupload: Error - -------");
                        console.log(jqXHR.status);
                        console.log(statusText);
                        console.log(errorThrown);
                        console.log(jqXHR.responseText);
                        if (jqXHR.status == "200")
                        {
                            render_picture(result.id);
                        }
                        else
                        {
                            var obj = jQuery.parseJSON(jqXHR.responseText);
                            // console.log(typeof obj["attachment"][0])
                            setUpPurrNotifier("info.png", "Notice", obj["attachment"][0]);
                            data.context.remove();
                        }
//                        if (jqXHR.statusText == "success") {
//                            render_pictures();
//                            // It succeeded and we need to update the file list.
//                        }
//                        else {
//                            var obj = jQuery.parseJSON(jqXHR.responseText);
//                            setUpPurrNotifier("info.png", "Notice", obj["attachment"][0]);
//                            data.context.remove();
//                        }

                    })
                    .complete(function (result, textStatus, jqXHR) {
                        // console.log("------ - fileupload: Complete - -------");
                        // console.log(result);
                        // console.log(textStatus);
                        // console.log(jqXHR);
                    });
        },
        progress: function (e, data) {
            if (data.context)
            {
                progress = parseInt(data.loaded / data.total * 100, 10);
                data.context.find('.bar').css('width', progress + '%');
            }
        },
        done: function (e, data) {
            // console.log(e);
            // console.log(data);
            data.context.text('');
        }
    }).bind('fileuploaddone', function (e, data) {
        // console.log(e);
        // console.log(data);
        data.context.remove();
        //data.context.text('');
    });
}

function bind_download_to_files()
{
    $("div.file-item div#logo-links").unbind("click");
    $("div.file-item div#logo-links").bind("click",
            function () {
                var href = $($(this)[0]).find('a').attr('href');
                window.location.href = href
            });
}

function render_pictures(product_id) {
    $.ajax({
        dataType: "html",
        url: '/pictures/render_pictures',
        cache: false,
        data: "class_name=product&id=" + product_id,
        success: function (data)
        {
            $("div#images").html(data).hide().fadeIn();

            max_images = $('#max-images').text();

            if (max_images.length > 0)
            {
                total_images = $("div.file-list-item").size();
                if (total_images >= max_images) {
                    $("div#imagebutton").fadeOut();
                }

            }
            bind_file_upload_to_upload_form();


        }
    });

}

function render_picture(picture_id) {
    $.ajax({
        dataType: "html",
        url: '/pictures/render_picture',
        cache: false,
        data: "class_name=product&id=" + picture_id,
        success: function (data)
        {
            $("div#images").prepend(data).hide().fadeIn();

            max_images = $('#max-images').text();

            if (max_images.length > 0)
            {
                total_images = $("div.file-list-item").size();
                if (total_images >= max_images) {
                    $("div#imagebutton").fadeOut();
                }

            }

            bind_file_upload_to_upload_form();
            bindDeleteImage();
            bind_mouseover();
            activate_buttons();
            initialize_edit_button();
            bind_download_to_files();


        }
    });

}


$(document).off('focusin').on('focusin', function (e) {
    if ($(event.target).closest(".mce-window").length) {
        e.stopImmediatePropagation();
        console.log("worked!");
    }
});

// binds the download attachment link for each attached file.

function bind_download_to_files()
{
    $("div.file-item div#logo-links").unbind("click");
    $("div.file-item div#logo-links").bind("click",
            function () {
                var href = $($(this)[0]).find('a').attr('href');
                window.location.href = href
            });
}
function bindPicturesSort() {


    $('div#images').sortable({
        dropOnEmpty: false,
        handle: 'div.file-item',
        cursor: '-webkit-grabbing',
        items: 'div.file-list-item',
        opacity: 0.4,
        scroll: true,
        tolerance: "pointer",
        update: function () {
            console.log($(this));
            $.ajax({
                url: '/products/update_image_order',
                type: 'post',
                data: $(this).sortable('serialize'),
                dataType: 'json',
                complete: function (request) {
                }
            });
        }
    });

}

function bindDeleteImage() {
    $('a.picture-delete').unbind().bind('ajax:beforeSend', function () {
        // alert("ajax:before");  
    }).bind('ajax:success', function () {
        console.log($(this).parent().parent());
        $(this).parent().parent().remove();
        //  alert("ajax:success");  
    }).bind('ajax:failure', function () {
        //    alert("ajax:failure");    
    }).bind('ajax:complete', function () {
        //   alert("ajax:complete"); 
    });

}

//  Picture management routines

function initialize_edit_button()
{
    $("a.edit-picture-product").unbind()
            .bind("ajax:beforeSend", function (evt, xhr, settings) {
                //alert("ajax:beforeSend");
            })
            .bind("ajax:success", function (evt, data, status, xhr) {
                // alert("ajax:success");
                edit_picture_dialog(data);
            })
            .bind('ajax:complete', function (evt, xhr, status) {
                //alert("ajax:complete");
            })
            .bind("ajax:error", function (evt, xhr, status, error) {
                //  alert("ajax:error");

                var $form = $(this),
                        errors,
                        errorText;

                try {
                    // Populate errorText with the comment errors
                    console.log(xhr);
                    console.log(status);
                    console.log(error);

                    errors = $.parseJSON(xhr.responseText);
                    console.log(errors);

                } catch (err) {
                    // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
                    errors = {
                        message: "Please reload the page and try again"
                    };
                }
                var errorText;
                // Build an unordered list from the list of errors
                errorText = "<ul>";

                for (error in errors) {
                    console.log(error);
                    console.log(errors[error][0]);
                    errorText += "<li>" + error + ': ' + errors[error][0] + "</li> ";
                    console.log(errorText);
                }

                errorText += "</ul>";
                console.log(errorText);

                // Insert error list into form
                setUpNotifier("error.png", "Warning", errorText);
            });

}



function edit_picture_dialog(data) {

    // alert("ajax:success");
    picture_edit_dialog = createAppDialog(data, "edit-picture", {}, "");

    picture_edit_dialog.dialog({
        close: function (event, ui) {
            picture_id = $("div#picture-id").text().trim();
            value = $("select#picture_title").val();
            $("div#picture_" + picture_id + " div.picture-info").text(value);
        }
    });

    //initialize_save_button();
    //$('.datepicker').datepicker();
    //tiny_mce_initializer();
    //bind_org_select();
    //bind_membership_select();
    //bind_grade_select();
    //bind_flags_select();

    //bind_grade_all_select();

    //bind_grade_filter_display();
    //bind_membership_filter_display();
    //bind_flags_filter_display();
    //bind_select_ajax("picture_priority");
    //bind_select_ajax("picture_status");



    //current_notice = $("#picture-id").text();
    //set_before_edit(current_notice);
    // tinyMCE.init({"selector":"textarea.tinymce"});
    $(".best_in_place").best_in_place();
    ui_ajax_select();
    //bind_file_upload_to_upload_form();
    //$("button.ui-dialog-titlebar-close").hide();

    //initialize_add_organization();
    //select_subject_field();
    //initialize_select_all_button();
    //initialize_select_none_button();
    //initilize_filter_buttons();

}

function activate_buttons() {

    $("div.ui-button a").button();
}

function bind_mouseover()
{

    $("div.file-block")
            .unbind("mouseenter").mouseenter(function () {
        $(this).parent().find("div.hover-block").fadeIn();
        // console.log("fadeIn");
    })
            .unbind("mouseleave").mouseleave(function () {
        $(this).parent().find("div.hover-block").fadeOut();
        //   console.log("fadeOut");
    });
}


function wait(msecs)
{
    var start = new Date().getTime();
    var cur = start
    while (cur - start < msecs)
    {
        cur = new Date().getTime();
    }
}


function buildproductDetailsListTable() {
    var $product_id = $("#product-id").text();

    productDetailsTable = $('#product-detail-list-table').dataTable({
        "iDisplayLength": 25,
        "aLengthMenu": [[25, 50, 100], [25, 50, 100]],
        "bStateSave": true,
        "bProcessing": true,
        "bServerSide": true,
        "sAjaxSource": "/product_details/product_details_table" + "?" + "product_id=" + $product_id,
        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
            //  $(nRow).addClass('product-row');
            // $(nRow).addClass('gradeA');

            return nRow;
        },
        "aoColumns":
                [
                    {
                        "sWidth": "25"
                    },
                    {
                        "sWidth": "200"
                    },
                    {
                        "sWidth": "200"
                    },
                    {
                        "sWidth": "300"
                    },
                    {
                        "sWidth": "100"
                    },
                    {
                        "sWidth": "100"
                    },
                    {
                        "sWidth": "50"
                    }
                ]
        ,
        "fnDrawCallback": function () {
            $(".best_in_place ").best_in_place();
            $(".combobox").combobox();
            $("#toggle").click(function () {
                $("#combobox").toggle();
            });

            bindChangeColor();
            ui_ajax_select();
            bindDeleteProductDetail();
            bindDuplicateProductDetail();


            //bindClicktoProductTableRow();
        }
    });

    // $("#product-detail-list-table").css("width","100%")

}

//function setUpPurrNotifier(headline, message)
//{
//    var notice = '<div class="notice">'
//    + '<div class="notice-body">'
//    + '<img src="/images/interface/info.png" />'
//    + '<h3>' + headline + '</h3>'
//    + '<p>' + message + '</p>'
//    + '</div>'
//    + '<div class="notice-bottom">'
//    + '</div>'
//    + '</div>';
//
//    $( notice ).purr();
//    alert("testing");
//};

function buildproductDetailsListTableOLD()
{
    productDetailsTable = $('#product-detail-list-table').dataTable({
        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]],
        "fnDrawCallback": function () {
            $(".best_in_place ").best_in_place();
            $(".combobox").combobox();
            $("#toggle").click(function () {
                $("#combobox").toggle();
            });
            bindChangeColor();

        }
    });

}

$.extend({
    getUrlVars: function () {
        var vars = [], hash;
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        for (var i = 0; i < hashes.length; i++)
        {
            hash = hashes[i].split('=');
            vars.push(hash[0]);
            vars[hash[0]] = hash[1];
        }
        return vars;
    },
    getUrlVar: function (name) {
        return $.getUrlVars()[name];
    }
});


function bindImageChage() {

    //
    //
    // image class bindings
    //

    $('input#image').bind("change", function () {
        //alert("changed");
        toggleLoading();
        toggleAddButton();
        $(this).closest("form").trigger("submit");
        $(".imageSingle .best_in_place").best_in_place();
        disableSelectOptionsSeperators();

    });

}

function updateBestinplaceImageTitles() {
    $(".imageSingle .best_in_place").best_in_place();

}

function refreshProductDetails() {
    productDetailsTable.fnDraw(true);
    $("body").css("cursor", "default");

    //   $("#loader_progress").hide();

//    var $product_id = $("#product-id").text();
//    $("#loader_progress").hide();
//
//    $.post('/products/show_detail/' + $product_id, function(data)
//    {
//        $('#product-detail-list').html(data);
//        $("#loader_progress").hide();
//        buildproductDetailsListTable();
//        $(".details-row .best_in_place").best_in_place();
//        $(".combobox").combobox();
//
//    });

}

function bindProductDetailNew()
{
    $('#new-product-detail-item').on('ajax:success', function (xhr, data, status) {
        refreshProductDetails();

    }).on('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();

    });






}
;

function bindDeleteProductDetail() {
    $('.delete-product_detail').on('ajax:success', function (xhr, data, status) {
        refreshProductDetails();
        // $("#loader_progress").show();
//        theTarget = this.parentNode.parentNode;
//        var aPos = productDetailsTable.fnGetPosition(theTarget);
//        productDetailsTable.fnDeleteRow(aPos);
        //  $("#loader_progress").hide();
        $("body").css("cursor", "default");

    }).on('ajax:beforeSend', function (e, xhr, settings) {
        //xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        // $("#loader_progress").show();
        $("body").css("cursor", "progress");

    });
    ;

}

function bindDuplicateProductDetail() {

    $('.duplicate-product_detail').on('ajax:success', function (xhr, data, status) {
        refreshProductDetails();
        // alert("duplicated");

    }).on('ajax:beforeSend', function (e, xhr, settings) {
        //xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        // $("#loader_progress").show();
        $("body").css("cursor", "progress");

    });
}


function bindBlurToDepartmentPopup() {

    $('#product_department_id').change(function () {

        var $product_id = $("#product-id").text();
        // $("#product_department_id").val()
        setTimeout(function () {

            $.post('/products/render_category_div?id=' + $product_id, function (data)
            {
                $('#category-div').html(data);
                // $("#loader_progress").hide();
                //bindBlurToDepartmentPopup();
            });
        }, 100);
        //alert('Handler for .blur() called.');
    });
    $('.department-check').change(function () {

        var $product_id = $("#product-id").text();
        // $("#product_department_id").val()
        setTimeout(function () {

            $.post('/products/render_category_div?id=' + $product_id, function (data)
            {
                $('#category-div').html(data);
                // $("#loader_progress").hide();
                //bindBlurToDepartmentPopup();
            });
        }, 100);
        //alert('Handler for .blur() called.');
    });
}

function updateImages() {

    //  alert("color changed");
    var $product_id = $("#product-id").text();
    // $("#loader_progress").show();
    $("body").css("cursor", "progress");

    $.post('/products/render_image_section/' + $product_id, function (data)
    {
        $('.imagesection').html(data);
        $("body").css("cursor", "default");

        //  $("#loader_progress").hide();
        styleizefilebutton();
        bindImageChage();
        disableSelectOptionsSeperators();

    });

}


function BestInPlaceCallBack(input) {
    //    if(input.data.indexOf("product_detail[color]") != -1)
    if (input.attributeName.indexOf("color") != -1)
    {
        //  alert("color changed");
        var $product_id = $("#product-id").text();
        $("body").css("cursor", "progress");
//$("#loader_progress").show();

        $.post('/products/render_image_section/' + $product_id, function (data)
        {
            $('.imagesection').html(data);
            $("body").css("cursor", "default");
            // $("#loader_progress").hide();
            styleizefilebutton();
            bindImageChage();

        });
    }
}
;




function ajaxSave()
{

    tinyMCE.triggerSave();

    $("#product_product_description_save").closest("form").trigger("submit");

}

function bindChangeColor() {

    $('.combobox').change(function () {
        var $detail_id = $(this).parent().parent().find("#detail-id").text();
        var value = $(this).val();
        console.log($detail_id);
        //   "/products/update_ajax/1?field=color&pointer_class=ProductDetail"
        $.ajax({
            url: '/product_details/' + $detail_id,
            data: {"product_detail": {"color": value}},
            method: "put",
            dataType: "json",
            success: function (data) {
                $(this).html(data);
                updateImages();

            }
        })
    });
}


function test() {
    $('#details_color').bind("change", function () {
        $("body").css("cursor", "progress");

        // $("#loader_progress").show();

        wait(5000);
        updateImages();
        alert("images updated");
        //alert("changed");

    }).on('ajax:success', function (xhr, data, status) {
        alert("changed");

    });

}




function bindDivDepartmentUpdate() {
    $('.div-department form').bind('ajax:beforeSend', function () {
        // show spinner
        // alert("ajax:before");  
    }).bind('ajax:success', function () {
        updateCategoryDiv();
        //alert("ajax:success");  
    }).bind('ajax:failure', function () {
        //  alert("ajax:failure");    
    }).bind('ajax:complete', function () {
        //hide spinner
        // alert("ajax:complete");  

    });

}

function updateCategoryDiv() {


    var $product_id = $("#product-id").text();
    // $("#product_department_id").val()

    $.post('/products/render_category_div?id=' + $product_id, function (data)
    {
        $('#category-div').html(data);
        $("body").css("cursor", "default");
// $("#loader_progress").hide();
        // setupCheckboxes(".category-check");
    });
}

function mysave() {
    console.log("trigger save");
    tinymce.triggerSave();
    // $("#page-body-save").closest("form").trigger("submit");
    $("#product_product_description").parent().parent().closest("form").trigger("submit");

}

function set_up_save_callback() {

    $("form.edit_product")
            .on("ajax:success", function (event, data, status, xhr) {
                //   console.log(event);
                //   console.log(data["notice"]);
                //  console.log(status);
                //   console.log(xhr);
                setUpPurrNotifier("Attention", data["notice"]);
                $('iframe.preview').attr("src", $('iframe.preview').attr("src"));

            });
}
