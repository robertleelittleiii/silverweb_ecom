/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// TODO:  Add ajax function to load pictures based on properties object.


var notice = ""

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
//    if (message.length > 1) 
//    {
//        $(notice).purr();
//    }
//    
//    
//}
    
    


$(document).ready(function(){
    
    bindProductActions();
  bindChangeShipping() ; 
    // check for full screen and adjust layout
    if ($("#full-screen").html().trim() == "true")
    {
        $("div#page-middle-left").hide();
        $("div#content").width("100%");
        $('#Content').css('background',"white")

    }
   

 
});


function bindChangeShipping(){


    $('#cart_shipping_type').change(function() {

        //alert("changed");
        //cart_item_id=$(this).parent().parent().find("#cart-item-index").html().trim()
        //updateShoppingCartItemInfo($(this).parent().parent().find(".shopping-cart-item-info"), cart_item_id)
        setTimeout(function() {
            updateShoppingCartSummary();
        },1250);
        
        
       //;
        //updateShoppingCartView();
       // $(this).parent().parent().find(".shopping-cart-item-info").html(
        
        
       // alert("add success");
        $("#loader_progress").hide();


    });
    
}

function updateCartContents() {
            $.ajax({
            url: "/site/get_cart_contents",
            dataType: "html",
            type: "GET",
            data: "" ,
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                //display warning
                }
                else
                {
                   $("#cart-contents").html(data);
                   
                }
            }
        });
    
}


function updateShoppingCartView() {
            $.ajax({
            url: "/site/get_shopping_cart_info",
            dataType: "html",
            type: "GET",
            data: "" ,
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                //display warning
                }
                else
                {
                   $("#shopping-cart-info").html(data);
                }
            }
        });
    
}


function updateShoppingCartItemInfo(item_to_update, item_id) {
            $.ajax({
            url: "/site/get_shopping_cart_item_info",
            dataType: "html",
            type: "GET",
            data: "item_no="+ item_id ,
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                //display warning
                }
                else
                {
                   $(item_to_update).html(data);
                console.log(item_to_update);
                }
            }
    
        }).fail(function(jqXHR, textStatus) {
  alert( "Request failed: " + textStatus );
});;
    
}

function updateShoppingCartSummary() {
            $.ajax({
            url: "/site/get_cart_summary_body",
            dataType: "html",
            type: "GET",
            data: "",
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                //display warning
                }
                else
                {
                   $(".cart-summary-body").html(data);
                   if (parseFloat($("#cart-total-price").text().replace(/\$|,/g, '')) == 0)
                       {
                        //alert("Cart is empty");
                        window.location="/site?alert=The%20cart%20is%20now%20empty.";
                }
            }
            }
        });
    
}



function bindProductActions ()
{
    $('.add-product').live('ajax:success', function(xhr, data, status){
        cart_item_id=$(this).parent().parent().find("#cart-item-index").html().trim()
        updateShoppingCartItemInfo($(this).parent().parent().find(".shopping-cart-item-info"), cart_item_id)
        updateShoppingCartSummary();
        updateShoppingCartView();
       // $(this).parent().parent().find(".shopping-cart-item-info").html(
        setUpPurrNotifier("Inventory Warning",data)

        
       // alert("add success");
        $("#loader_progress").hide();


    }).live('ajax:beforeSend', function(e, xhr, settings){
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();

    });

    $('.minus-product').live('ajax:success', function(xhr, data, status){
        cart_item_id=$(this).parent().parent().find("#cart-item-index").html().trim();
        updateShoppingCartItemInfo($(this).parent().parent().find(".shopping-cart-item-info"), cart_item_id);
        updateShoppingCartSummary();
        updateShoppingCartView();
       // console.log(this);
        item_quantity = $(this).parent().parent().find("#item-quatity").text().trim();
      // console.log(item_quantity);
       
        if (item_quantity == "1") 
            {
                $(this).parent().parent().hide();
            }
            else
                {
                    $(this).parent().parent().show();
                }
            
       // alert("minus success");
                $("#loader_progress").hide();


    }).live('ajax:beforeSend', function(e, xhr, settings){
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();

    }).live('ajax:fail', function(xhr, status, error) {
        $(this).parent().parent().hide();
         alert('error');
    });



    $('.remove-product').live('ajax:success', function(xhr, data, status){
        
        updateCartContents();
        bindProductActions();
        updateShoppingCartSummary();
        updateShoppingCartView();
        
        // alert("remove success");
        $("#loader_progress").hide();
    }).live('ajax:beforeSend', function(e, xhr, settings){
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();

    });


};

function BestInPlaceCallBack(input) {
  //  console.log(input);
    $("#loader_progress").show();

    if (input.attributeName=="coupon_code")
    {
        $.post('/site/get_cart_summary_body', function(data)
        {
            $('.cart-summary-body').html(data);
            $("#loader_progress").hide();
        });
        // alert("hello");
    }
//    if(input.data.indexOf("product_detail[color]") != -1)
//    {
//        //  alert("color changed");
//        var $product_id = $("#product-id").text();
//        $("#loader_progress").show();
//
//        $.post('/products/render_image_section/' + $product_id, function(data)
//        {
//            $('.imagesection').html(data);
//            $("#loader_progress").hide();
//            styleizefilebutton();
//            bindImageChage();
//
//        });
//    }
} ;
