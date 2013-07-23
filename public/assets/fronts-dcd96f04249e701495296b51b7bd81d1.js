(function() {
  var add_remove_active_class, show_hide_header_link;

  window.refresh_linkedin_data = function(msg) {
    if (confirm(msg)) {
      $("#spinner").show();
      return window.location.href = $("#refresh_lnk_id").attr('href');
    }
  };

  window.callAjaxRequest = function(email, ssUrl) {
    $.ajax({
      type: "GET",
      dataType: 'html',
      data: {
        email: email
      },
      url: ssUrl,
      success: function(result) {}
    });
    return false;
  };

  add_remove_active_class = function(div_param, remove) {
    if (remove == null) {
      remove = true;
    }
    if (remove) {
      return $(div_param).removeClass('active');
    } else {
      return $(div_param).addClass('active');
    }
  };

  show_hide_header_link = function(div_param, hide) {
    if (hide == null) {
      hide = true;
    }
    if (hide) {
      return $(div_param).hide();
    } else {
      return $(div_param).show();
    }
  };

  $(function() {
    $("input:text").eq(0).focus();
    $('#notice').delay(4000).animate({
      height: '0px',
      opacity: 0
    });
    $('#error').delay(4000).animate({
      height: '0px',
      opacity: 0
    });
    $('#subscribe_lnk').click(function(e) {
      return $("#spinner").show();
    });
    $("#invite_btn").click(function(e) {
      var user_email;
      user_email = $('#user_email').val();
      if (!user_email) {
        return alert("Please enter email address");
      } else {
        $.ajax({
          type: 'GET',
          dataType: 'json',
          data: {
            email: user_email
          },
          url: "/is_email_invited",
          success: function(res) {
            if (res.result) {
              if (confirm("You already sent your cv to " + user_email + " on " + res.invited_date + ". Do you wish to send it again?")) {
                $("#spinner").show();
                return document.forms[0].submit();
              }
            } else {
              $("#spinner").show();
              return document.forms[0].submit();
            }
          }
        });
        return false;
      }
    });
    $("#stepform1, #stepform11").click(function(e) {
      show_hide_header_link('#stepcontent2, #stepcontent3, #stepcontent4, #stepcontent5');
      add_remove_active_class('#stepform2, #stepform3, #stepform4, #stepform5');
      show_hide_header_link('#stepcontent1', false);
      return add_remove_active_class('#stepform1', false);
    });
    $('#stepform2, #stepform22').click(function(e) {
      show_hide_header_link('#stepcontent1, #stepcontent3, #stepcontent4, #stepcontent5');
      add_remove_active_class('#stepform1, #stepform3, #stepform4, #stepform5');
      show_hide_header_link('#stepcontent2', false);
      return add_remove_active_class('#stepform2', false);
    });
    $('#stepform3, #stepform33').click(function(e) {
      show_hide_header_link('#stepcontent2, #stepcontent1, #stepcontent4, #stepcontent5');
      add_remove_active_class('#stepform2, #stepform1, #stepform4, #stepform5');
      show_hide_header_link('#stepcontent3', false);
      return add_remove_active_class('#stepform3', false);
    });
    $('#stepform4, #stepform44, #stepform66').click(function(e) {
      show_hide_header_link('#stepcontent2, #stepcontent3, #stepcontent1, #stepcontent5');
      add_remove_active_class('#stepform2, #stepform3, #stepform1, #stepform5');
      show_hide_header_link('#stepcontent4', false);
      return add_remove_active_class('#stepform4', false);
    });
    return $('#stepform5, #stepform55').click(function(e) {
      show_hide_header_link('#stepcontent2, #stepcontent3, #stepcontent1, #stepcontent4');
      add_remove_active_class('#stepform2, #stepform3, #stepform1, #stepform4');
      show_hide_header_link('#stepcontent5', false);
      return add_remove_active_class('#stepform5', false);
    });
  });

}).call(this);
