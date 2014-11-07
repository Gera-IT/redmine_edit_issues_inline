/**
 * Created by alex on 9/19/14.
 */


$(document).ready(function() {
    jQuery(".best_in_place").best_in_place();
    $('.best_in_place').bind("ajax:error", function(request, error){
        console.log(error);
        console.log(request);
        var result;
        if (error.status == 422)
            {
                var result = confirm("It seems like some fields that requires your attention were added after you last time updated this issue. " +
                    "You need to fill them before you can use this editor. These are errors:" + error.responseText + '. Clicking ok will redirect you to issue page');
            }
        else
            {
                var result = ("Seems like you've found an error. Please report to redmine administrator about this and it will get fixed. Clicking ok will redirect you to issue page")
            }
        if (result) {
            window.location = "/issues/" + request.target.dataset.id
        }
        else
        {

        }
    });

    $('.subject_link').click(function(e){

        if ($(this).children().first().hasClass("update_issue_change_label") || $(this).children().first().hasClass("new_issue_change_label") )
        {}
        else if  ($(this).children().length > 0)
        {
            e.preventDefault();
        }
    })
});




jQuery(function(){
    jQuery(".has_datepicker").datepicker();
    $('.subject_link').click(function(e){
        if ($(this).children.length == 0)
        {
            alert("length 0");
            e.preventDefault();
        }
    })
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


    $('.issues tbody tr').on('mouseenter', function(e){
        $('#' + $(this).attr('id') + '-subject').show();
    });

    $('.issues tbody tr').on('mouseleave', function(e){
        $('#' + $(this).attr('id') + '-subject').hide();
    })
});
