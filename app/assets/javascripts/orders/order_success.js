/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// TODO:  Add ajax function to load pictures based on properties object.


function bindZoomClick() {
    $("#zoom-invoice").click(function(){
        var zoomName= $("#zoom-invoice").text() 
    
        if(zoomName == "Zoom Invoice") {
            $("#zoom-invoice").text("Shrink Invoice")
            $('#invoice-frame').effect('scale', {
                scale:'content',
                percent:250
            }, 1000, function(){
                $("#invoice-tools").width("1000px");

                
                
            });
        }
           
        else
        {
            $("#zoom-invoice").text("Zoom Invoice")
            $('#invoice-frame').effect('scale', {
                scale:'content',
                percent:40
            }, 1000, function() {
                $("#invoice-tools").width("585px");

                
            });
        }   
            
    
    //  $('#invoice-frame').effect('scale', {scale:'content',percent:40}, 1000);
       
        
    });   
}


$(document).ready(function(){
    bindZoomClick();
    $('#invoice-frame').effect('scale', {
        scale:'content',
        percent:40
    }, 1000);
    
});

