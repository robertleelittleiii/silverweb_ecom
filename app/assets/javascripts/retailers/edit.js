var retailers_edit_callDocumentReady_called = false;

$(document).ready(function () {
    if (!retailers_edit_callDocumentReady_called)
    {
        retailers_edit_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        } else
        {
            retailers_edit_callDocumentReady();
        }
    }
});

function retailers_edit_callDocumentReady() {

    $(".best_in_place").best_in_place();

}









