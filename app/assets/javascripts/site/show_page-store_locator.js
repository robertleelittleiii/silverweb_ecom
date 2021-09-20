/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

$(document).ready(function(){
        require("jquery.storelocator.js");
        require("handlebars-1.0.0.js");

    
        $('#map-container').storeLocator({'dataType': 'json', 'dataLocation': '/site/retailers.json'});
});
