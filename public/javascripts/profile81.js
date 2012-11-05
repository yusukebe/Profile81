$().ready(function(){
    $('.recommend-tag').click(function(){
        var label = $(this).text();
        $('#tag-input').val( $('#tag-input').val() + ' ' + label );
        return false;
    });
});