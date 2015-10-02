function bindThumbHover()
{
//   $('.product-thumb').click(function(){
        
//   theTitle = $(".product-picture").attr("title");
//   newContent = '<a href="'+$(this).attr('src').replace('small_','') +'" class="product-picture" title="'+theTitle+'"><img src="'+ $(this).attr('src').replace('small_','view_') +'"></a>';
//   $("#product-main-image").html(newContent);
    
//  $('.product-picture img').attr('src',$(this).attr('src').replace('small_','view_'));
//  $('.product-picture').attr("href",$(this).attr('src').replace('small_',''));
      
//   $(".zoomWrapperImage img").attr("src",$(this).attr('src').replace('small_',''));
//   $(".zoomPad img").attr("src",$(this).attr('src').replace('small_','view_'));
    
//$('a.product-picture').jqzoom({
//         zoomType: 'innerzoom'
//  });
//$(".product-picture").attr("href");
//$(".product-picture img").attr("src");
    
//$('#description').html($(this).attr('alt'));
//});
    
}
var notice = ""

function setUpdialog(headline, message)
{
    var notice = '<div id="dialog" title="'+headline+'">'
    + '<p>' + message + '</p>'
    + '</div>';
    if (message.length > 1) 
    {
        $(notice).dialog({
            width: 575,
            height:490
        }).css( {
            'max-height' : '750px'
        } );;

    }
    
    
}
$(document).ready(function(){
    bind_hover_to_swatch();
    });

function bind_hover_to_swatch() {
    $('img.product-swatch').hover(function() {
        $(this).addClass('transition');
    
    }, function() {
        $(this).removeClass('transition');
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

function bindSwatchClick() {
    $(".product-swatch").click(function(){

        $(".product-swatch").each(function(i,o){
            $(o).removeClass("swatch-selected "); 
        });
        
        $(this).addClass("swatch-selected ")
        $("#product-selected-color").html($($(this).parent()).find("#color-name").html());
        var product_color = $("#product-selected-color").html().trim();
        var product_id = $("#product-id").html().trim();

        $.ajax({
            url: "/site/get_sizes_for_color",
            dataType: "html",
            type: "GET",
            data: "id="+product_id+ "&color="+product_color ,
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                //display warning
                }
                else
                {
                    $("#product-size-items").html(data);
                    $("#product-selected-size").html($(".size-selected").html().strip());
                    bindSizeClick();
                }
            }
        });
        
    });
    
    
}

function bindSizeClick() {
    $(".product-size-item").click(function(){
        $(".product-size-item").each(function(i,o){
            $(o).removeClass("size-selected "); 
        });
        
        $(this).addClass("size-selected ")
        $("#product-selected-size").html($(this).html());

    });
    
    
}

function bindSizeChartClick() {
    $("#product-size a").click(function(){
        var distributor_info = $("#distributor-info").text().trim();
        $.ajax({
            url: "/site/show_page_popup",
            dataType: "html",
            type: "Get",
            data: "page_name="+distributor_info+" Sizing",
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                //display warning
                }
                else
                {
                    setUpdialog("Size Chart", data)
                //alert("success");
                }
            }
        });
    });
    return( false);
    
}
function bindCareChartClick() {
    $("#product-colors a").click(function(){
        var distributor_info = $("#distributor-info").text().trim();
        $.ajax({
            url: "/site/show_page_popup",
            dataType: "html",
            type: "Get",
            data: "page_name="+distributor_info+" Care",
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                //display warning
                }
                else
                {
                    setUpdialog("Care Instructions", data)
                //alert("success");
                }
            }
        });
    });
    return( false);
    
}

function bindAddToCartClick() {
    $("#add_to_cart").click(function(){
        var product_id = $("#product-id").html().trim();
        var product_size = $("#product-selected-size").html().trim();
        var product_color = $("#product-selected-color").html().trim();
        var product_name = $("#product-name").text().trim();
        var product_quantity  = $("input#quantity").val();  
        $.ajax({
            url: "/site/add_to_cart",
            dataType: "html",
            type: "Get",
            data: "id="+product_id+ "&color="+product_color + "&size=" + product_size +"&quantity="+product_quantity,
            success: function (data)
            {
                    setUpPurrNotifier("Added to Cart", product_quantity + " " + product_name+ "<br> Size: "+ product_size + "(" + product_color +")" );

                // alert(data);
                if (data === undefined || data === null || data === "")
                {
                    updateShoppingCartView(); 
                //display warning
                }
                else
                {
                    setUpPurrNotifier("Inventory Warning",data)
                    updateShoppingCartView(); 
                //alert("success");
                }
            }
        });
    });
   
}

function addCommas(nStr)
{
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
}


function bindLiveActionOnQuantity () {
    $("input#quantity").bind("keyup focusout",function(a,b){
        
        var price = (parseFloat($("input#quantity").val()||0)*parseFloat($("#product-price").html().trim().replace(",","").substr(1,100))).toFixed(2);
        
        if (isNaN(price) || (price < 0))
        {
            $("input#quantity").val(1)
            $("#total-cost-dollars").html($("#product-price").html());
        }
        else
            $("#total-cost-dollars").html("$" + addCommas(price));
    });
  
  
//  #total-cost-dollars
   
}

function mycarousel_initCallback(carousel) {
    
   // alert("init-callback");
    $('.jcarousel-control a').bind('click', function() {
        carousel.scroll($.jcarousel.intval($(this).text()));
        return false;
    });

    $('.jcarousel-scroll select').bind('change', function() {
        carousel.options.scroll = $.jcarousel.intval(this.options[this.selectedIndex].value);
        return false;
    });

    $('#mycarousel-next').on('click', function() {
        //alert("next");
        carousel.next();
        return false;
    });

    $('#mycarousel-prev').on('click', function() {
       // alert("prev");
        carousel.prev();
        return false;
    });
};


$(document).ready(function(){
   // require("jquery.jcarousel.js");
    
    $("ul.style-image-items").jcarousel({
      scroll: 3,
      wrap: 'circular',
        initCallback: mycarousel_initCallback,
        // 'list': 'ul.style-image-items',
        // This tells jCarousel NOT to autobuild prev/next buttons
      buttonNextHTML: null,
        buttonPrevHTML: null
     });  
    
    
    bindSwatchClick();
    bindSizeClick();
    bindLiveActionOnQuantity();
    bindAddToCartClick();  
    bindSizeChartClick();
    bindCareChartClick();
    
    $('a.product-picture').jqzoom({
        zoomType: 'innerzoom'
    });
//    bindThumbHover();
});
				
                                
                                
      
//       <a href="/uploads/picture/image/44/M106UWIR-BLW-1.jpg?1337001332" class="product-picture" title="Wired"><img alt="View_m106uwir-blw-1" src="/uploads/picture/image/44/view_M106UWIR-BLW-1.jpg?1337001332"></a>
  

