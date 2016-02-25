/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


$(document).ready(function () {

    enableProductEdit();

});


function enableProductEdit() {
    if ($("div.edit-product").length > 0)
    {
        require("products/shared.js");
        producteditClickBinding("div.edit-product");
    }
}

function ui_ajax_cart_select() {

    $("select.ui-ajax-cart-select").bind("change", function () {
        selected_item = $(this).val();
        controller = this.getAttribute("data-path")

        //alert(this.getAttribute("data-id"));


        $.ajax({
            url: controller, // controller + "/update",
            dataType: "json",
            type: "PUT",
            data: "id=" + this.getAttribute("data-id") + "&cart[" + this.getAttribute("name") + "=" + selected_item,
            success: function (data)
            {
                // alert(data);
                if (data === undefined || data === null || data === "")
                {
                    //display warning
                }
                else
                {

                }
            }
        });
    });
}

// live search 

function ajaxUpdateSearch(search_term) {

    var form = $("#live-search"); // grab the form wrapping the search bar.
    var url = "/site/live_product_search"; // live_search action.

    requireCss("site/live_product_search.css");
    require("site/show_products.js");

    updatePageForSearch();

    if (search_term == null)
    {
        var State = History.getState(); // Note: We are using History.getState() instead of event.state
        window.location.href = State.url;
        //       History.log(State.data, State.title, State.url);
        console.log("search_term == null");
        //    $("#search-image").removeClass("loading"); // hide the spinner
        $("body").css("cursor", "default");
        return;
    }

    if (queryString("search") == $("#live-search #live-search_search").val().trim())
    {
        console.log("skip update, already loaded");
        $("body").css("cursor", "default");
        // $("#search-image").removeClass("loading"); // hide the spinner

        return;
    }

    if (search_term == "")
    {
        var formValue = $("#live-search #live-search_search").val().trim();
        console.log("search_term == ''");
    }

    else
    {
        // $("#live-search #live-search_search").val(search_term);
        var formData = "search=" + search_term;
        var formValue = search_term.trim();
    }

    var full_search_url = url + "?search=" + formValue;

    $.ajax({
        url: full_search_url,
        cache: false,
        success: function (data) {
            // $("#page-left").hide();
            $("body").css("cursor", "default");

            // $("#search-image").removeClass("loading"); // hide the spinner

            $("#content").html(data); // replace the "results" div with the results


            // $("#mainnav").hide();// hide the admin menu
            $("#live-search_search").focus();
            $("#live-search_search").caretToEnd();
            // $("#page-middle-left").fadeOut("10s");
            location_url = window.location.url;
            ////console.log(location_url);
            history_url = "/site/live_product_search?search=" + formValue;
            history_url = history_url.replace(/^.*#/, '');
            ////console.log(history_url);

            History.pushState('statechange:', "Search for '" + formValue + "'", history_url);
            // History.log('statechange:', "Search for '"+ formValue +"'", history_url);

            //  History.pushState("","",history_url) 
            $("body").css("cursor", "default");

            // $("#search-image").removeClass("loading"); // hide the spinner
            // $("#live-search #live-search_search").val(formValue);

            // updateSearchFormBindings();
            bindClickToProductItem();
            //alert('Load was performed.');
        },
        error: function (jqXHR, textStatus, errorThrown) {
            // document.location.href = full_search_url;
            console.log(jqXHR);
            console.log(textStatus);
            console.log(errorThrown);

            return;
        }
    });
}


function updateSearchFormBindings() {

    // Executes a callback detecting changes with a frequency of 1 second
    $("#live-search_search").observe_field(1, function () {
        $("body").css("cursor", "wait");

        // $("#search-image").addClass("loading"); // show the spinner
        ajaxUpdateSearch("");

    });

    $("#live-search_search").keypress(function (e) {
        if (e.which == 13) {
            return false;
        }
    });

}

function queryString(key)
{
    var re = new RegExp("[?&]" + key + "=([^&$]*)", "i");
    var offset = location.search.search(re);
    if (offset == -1)
        return null;
    return RegExp.$1;
}



function enableHistory() {
    History = window.History; // Note: We are using a capital H instead of a lower h
    var State = History.getState(); // Note: We are using History.getState() instead of event.state
    //window.location.href=State.url;
    //  History.pushState(State.data, State.title, State.url);
    //History.log(State.data, State.title, State.url);
    
    if ( !History.enabled ) {
        // History.js is disabled for this browser.
        // This is because we can optionally choose to support HTML4 browsers or not.
        return false;
    }
            
       
        // Bind to StateChange Event
        History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
            var State = History.getState(); // Note: We are using History.getState() instead of event.state
            //       window.location.href=State.url;
            //       History.log(State.data, State.title, State.url);
            search_term = queryString("search");
            //       console.log("search_term =='" + search_term +"'");
            ajaxUpdateSearch (search_term);
        
        });

}