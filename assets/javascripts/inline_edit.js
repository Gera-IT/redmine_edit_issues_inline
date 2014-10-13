/**
 * Created by alex on 9/19/14.
 */


$(document).ready(function() {
    jQuery(".best_in_place").best_in_place();

//    $('.ui-datepicker-trigger').click(function (event) {
//        id = event.target.id;
//        console.log(id);
//        setTimeout($('#' + id).datepicker(), 2000);
//    })
});

$('.ui-datepicker-trigger').click(function (event) {
    id = event.target.id;
    console.log(id);
    setTimeout($('#' + id).datepicker(), 2000);
});

jQuery(function(){
//    $('.ui-datepicker-trigger').click(function (event) {
//        id = event.target.id;
//        console.log(id);
//        setTimeout($('#' + id).datepicker(), 2000);
//    });
    jQuery(".has_datepicker").datepicker();
});
