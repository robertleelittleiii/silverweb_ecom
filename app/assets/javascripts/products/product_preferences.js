/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var product_preferences_callDocumentReady_called = false;

$(document).ready(function () {
    if (!product_preferences_callDocumentReady_called)
    {
        product_preferences_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            product_preferences_callDocumentReady();
        }
    }
});

function product_preferences_callDocumentReady() {
    $("#product-settings-tabs").tabs();
    $(".best_in_place").best_in_place();
    ui_ajax_select();
    ui_ajax_settings_select();
    $("a.button-link").button();

    requireCss("image_libraries/image_list.css");
bind_file_upload_to_upload_form();
    bindImageChage();
    bind_download_to_files();
    bindPicturesSort();
    bindDeleteImage();
    bind_mouseover();
    activate_buttons();
    initialize_edit_button();
    $("a.button-link").button();
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


function updateImages() {

    //  alert("color changed");
    var $product_id = $("#product-id").text();
    $("#loader_progress").show();

    $.post('/products/render_image_section/' + $product_id, function (data)
    {
        $('.imagesection').html(data);
        $("#loader_progress").hide();
        styleizefilebutton();
        bindImageChage();
        disableSelectOptionsSeperators();

    });

}

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
    $("#loader_progress").show();

    $.post('/products/render_image_section/' + $product_id, function (data)
    {
        $('.imagesection').html(data);
        $("#loader_progress").hide();
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
    update: function(){
        console.log($(this));
      $.ajax({
        url: '/products/update_image_order',
        type: 'post',
        data: $(this).sortable('serialize'),
        dataType: 'json',
        complete: function(request){
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