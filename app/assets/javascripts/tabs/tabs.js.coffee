# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

add_remove_active_class = (div_param, remove=true) ->
  if remove
    $(div_param).removeClass('active')
  else
    $(div_param).addClass('active')  

  
show_hide_header_link = (div_param, hide=true) ->
  if hide    
    $(div_param).hide()
  else
    $(div_param).show()   

    
$ ->  
  $("#stepform1, #stepform11").click (e) ->
    alert 'hh'
    show_hide_header_link '#stepcontent2, #stepcontent3, #stepcontent4, #stepcontent5' 
    add_remove_active_class '#stepform2, #stepform3, #stepform4, #stepform5'
    show_hide_header_link '#stepcontent1', false
    add_remove_active_class '#stepform1', false      
        
  $('#stepform2, #stepform22').click (e) ->
    show_hide_header_link  '#stepcontent1, #stepcontent3, #stepcontent4, #stepcontent5'
    add_remove_active_class '#stepform1, #stepform3, #stepform4, #stepform5'
    show_hide_header_link '#stepcontent2', false
    add_remove_active_class '#stepform2', false
          
  $('#stepform3, #stepform33').click (e) ->
    show_hide_header_link '#stepcontent2, #stepcontent1, #stepcontent4, #stepcontent5'
    add_remove_active_class '#stepform2, #stepform1, #stepform4, #stepform5'
    show_hide_header_link '#stepcontent3', false
    add_remove_active_class '#stepform3', false
    
  $('#stepform4, #stepform44, #stepform66').click (e) ->
    show_hide_header_link '#stepcontent2, #stepcontent3, #stepcontent1, #stepcontent5'
    add_remove_active_class '#stepform2, #stepform3, #stepform1, #stepform5'
    show_hide_header_link '#stepcontent4', false
    add_remove_active_class '#stepform4', false
    
  $('#stepform5, #stepform55').click (e) ->
    show_hide_header_link '#stepcontent2, #stepcontent3, #stepcontent1, #stepcontent4'
    add_remove_active_class '#stepform2, #stepform3, #stepform1, #stepform4'
    show_hide_header_link '#stepcontent5', false
    add_remove_active_class '#stepform5', false