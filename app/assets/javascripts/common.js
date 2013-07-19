$(document).ready(function() {
  $("#div_update_search input").keyup(function() {
    callAjaxRequest($(this).val(), "/users", "div_update")
    return false;
  });  
  $("input:text").eq(0).focus();
  $('#notice').delay(4000).animate({height: '0px', opacity: 0});
  $('#error').delay(4000).animate({height: '0px', opacity: 0});
});  

$(document).keyup(function(e) {
  if (e.keyCode == 27) { $.prettyPhoto.close(); return false;}   // esc
});

function callAjaxRequest(email, ssUrl)
{
	jQuery.ajax({
		type:'GET',
		dataType:'html',
		data:{email: email},
		url:ssUrl,
		success:function(result){
		}
	})
}