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


BestInPlaceEditor.forms.date = {
    activateForm: function () {
        'use strict';
        var that = this,
            output = jQuery(document.createElement('form'))
                .addClass('form_in_place')
                .attr('action', 'javascript:void(0);')
                .attr('style', 'display:inline'),
            input_elt = jQuery(document.createElement('input'))
                .attr('type', 'text')
                .attr('name', this.attributeName)
                .attr('value', this.sanitizeValue(this.display_value));
        if (this.inner_class !== null) {
            input_elt.addClass(this.inner_class);
        }
        output.append(input_elt);

        this.element.html(output);
        this.setHtmlAttributes();
        this.element.find('input')[0].select();
        this.element.find("form").bind('submit', {editor: this}, BestInPlaceEditor.forms.input.submitHandler);
        this.element.find("input").bind('keyup', {editor: this}, BestInPlaceEditor.forms.input.keyupHandler);

        this.element.find('input')
            .datepicker({
                onClose: function () {
                    that.update();
                }
            })
            .datepicker('show');
    },

    getValue: function () {
        'use strict';
        return this.sanitizeValue(this.element.find("input").val());
    },

    submitHandler: function (event) {
        'use strict';
        event.data.editor.update();
    },

    keyupHandler: function (event) {
        'use strict';
        if (event.keyCode === 27) {
            event.data.editor.abort();
        }
    }
}

jQuery(function() {
    $.datepicker.setDefaults(datepickerOptions);
});
