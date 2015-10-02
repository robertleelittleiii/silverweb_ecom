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