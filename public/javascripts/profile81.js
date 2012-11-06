$().ready(function(){
    $('.recommend-tag').click(function(){
        var label = $(this).text();
        $('#tag-input').val( $('#tag-input').val() + ' ' + label );
        return false;
    });
    $('#profile-delete').click(function(){
        var ret = confirm('プロフィールを削除します。よろしいですか？');
        if(ret == true) {
        }else{
            return false;
        }
    });
});