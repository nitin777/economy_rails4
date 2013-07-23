# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


window.refresh_linkedin_data = (msg) ->
  if confirm msg
    $("#spinner").show()
    window.location.href = $("#refresh_lnk_id").attr('href')



window.callAjaxRequest = (email, ssUrl) ->
  $.ajax {
    type: "GET"
    dataType: 'html'
    data: {email: email}
    url: ssUrl 
    success: (result) ->
      # console.log(res)
  }
  false
    
$ ->
  $("input:text").eq(0).focus()
  
  $('#notice').delay(4000).animate
    height: '0px'
    opacity: 0
    
  $('#error').delay(4000).animate
    height: '0px'
    opacity: 0
    
  $('#subscribe_lnk').click (e) ->
    $("#spinner").show()
    
  $("#invite_btn").click (e) ->
    user_email = $('#user_email').val()
    if !user_email
      alert "Please enter email address"
    else
      $.ajax {
        type: 'GET'
        dataType: 'json'
        data: {email: user_email}
        url: "/is_email_invited"
        success: (res) ->
          if res.result
            if confirm "You already sent your cv to " +user_email+ " on " +res.invited_date+ ". Do you wish to send it again?"
              $("#spinner").show()
              document.forms[0].submit()
          else
            $("#spinner").show()
            document.forms[0].submit()
      }
      false