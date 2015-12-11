/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// TODO:  Add ajax function to load pictures based on properties object.

var site_show_products_callDocumentReady_called = false;


$(document).ready(function () {
    if (!site_show_products_callDocumentReady_called)
    {
        site_show_products_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            site_show_products_callDocumentReady();
        }
    }
});

function site_show_products_callDocumentReady() {
        
    // update left to correct height.
    $("#page-middle-left").height($("#page-body").height() + parseInt($("#page-body").css("margin-top")))


    bindClickToProductItem();

    require("products/shared.js");
    producteditClickBinding("div.edit-product");

    // check for full screen and adjust layout
    //if ($("#full-screen").html().trim() == "true")
    //{
    //    $("div#page-middle-left").hide();
    //    $("div#content").width("100%");
    //    $('#Content').css('background',"white")
    //}
    
    if ($('#slides').length > 0 )
    {
    $('#slides').slides({
        preload: true,
        preloadImage: '/images/interface/loading.gif',
        play: 5000,
        pause: 2500,
        slideSpeed: 1000,
        efect: 'slide',
        hoverPause: true,
        next: 'next-slide',
        prev: 'prev-slide'



    });	
    }
                   
    // resize the slider area and adjust the position of the prev next buttons.
    if ($(".slides_container").length > 0 ) 
    {
        $(".slides_container").width($("#slider-width").html().trim());
        $(".slides_container").height($("#slider-height").html().trim());
        $(".slides_container div").width($("#slider-width").html().trim());
        $(".slides_container div").height($("#slider-height").html().trim());
    
        //  slideshow_width = $("#slides").width();
        //  slideshow_height =$("#slides").height();
    
        slideshow_width =  parseInt($("#slider-width").html().trim());
        slideshow_height=  parseInt($("#slider-height").html().trim());
    
        slideshow_offset = $("#slides").offset();
        slideshow_middle = (slideshow_height / 2) - ($("#slides .next-slide").height() / 2);
  
        $("#slides .next-slide").offset({
            top: slideshow_middle + slideshow_offset.top, 
            left: slideshow_width + slideshow_offset.left
        });
        
        $("#slides .prev-slide").offset({
            top: slideshow_middle + slideshow_offset.top, 
            left: slideshow_offset.left - $("#slides .prev-slide").width()
        });


    };
    
    if ($("#admin-active").text() == "true") {
        // alert("Admin Active");
        setUpOrderChange();
        //bindProductMenu();
    }
};


function bindClickToProductItem () {
    $('.product-item').click(function(){
        //   console.log(this);
        window.location.href = $($(this)).find("a.product-detail-link").attr('href');

    //   $(this).find("a.product-detail-link").click();
    });
}



//
// Admin editor 
//

function orderUpdate(event, ui)
{
    alert("order changed!");
    console.log(event);
    console.log(ui);
}

function setUpOrderChange() {
    //    $( "#product-block" ).sortable({ 
    //        handle: "#edit-product" , 
    //        stop: function( event, ui ) {
    //            orderUpdate(event,ui);
    //        }
    //    });
    var currentPage = $("#page_number").text();
   
    $('#product-block').sortable({
        dropOnEmpty: false,
        items: 'div.product-item',
        handle: '.handle',
        cursor: '-webkit-grabbing',
        opacity: 0.4,
        scroll: true,
        update: function(){
            $.ajax({
                type: 'post',
                data: $('#product-block').sortable('serialize') + "&   page=" + currentPage,
                dataType: 'script',
                complete: function(request){
                    $('#product-block').effect('highlight');
                },
                url: '/products/sort'
            })
        }
    });
}

function bindProductMenu()
{
    
    $(".edit-product").hover(
        function () {
            $(this).append($("<div class='edit-product-menu'>Edit</br>To Next Page</br></div>"));
        },
        function () {
            $(this).find("div:last").remove();
        }
        );
  
}