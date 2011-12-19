$(document).ready ->
#/* helper functions */
  #/* esc escapes special characters in name */
  esc = (mySel) ->
    mySel.replace /([:|\.\]\[])/g, "\\$1"
    
  #/* simple validation */
  validateRequired = ->
    formElements = $(".required, .required-one")
    valid = true
    i = 0

    while i < formElements.length
      elm = formElements[i]
      type = elm.type.toLowerCase()
      node = elm.nodeName.toLowerCase()
      elm_valid = true
      if node is "input"
        type = elm.type.toLowerCase()
        if type is "text" or type is "password"
          elm_valid = not isEmpty(elm)
          (if elm_valid then clearError(elm) else setError(elm))
          valid = valid and elm_valid
        else if type is "radio" or type is "checkbox"
          elm_valid = isChecked(elm)
          (if elm_valid then clearError(elm) else setError(elm))
          valid = valid and elm_valid
      else if node is "textarea"
        elm_valid = not isEmpty(elm)
        (if elm_valid then clearError(elm) else setError(elm))
        valid = valid and elm_valid
      else if node is "select"
        elm_valid = isSelected(elm)
        (if elm_valid then clearError(elm) else setError(elm))
        valid = valid and elm_valid
      i++
    test = valid
    return (false)  unless valid
    true
    
  #/* validation: test element for empty or null */
  isEmpty = (e) ->
    v = e.value
    (not (v?)) or (v.length is 0)
    
  #/* validation: test select tag for selected */
  isSelected = (e) ->
    unless e.type is "select-one"
      return (if e.options then e.selectedIndex >= 0 else false)
    else
      return (if e.options then e.selectedIndex > 0 else false)
      
  #/* validation: test radio or checkbox for checked */
  isChecked = (e) ->
    ename = esc(e.name)
    ckd = $("input[name=\"" + ename + "\"]:checked")
    ckd.size() > 0
    
  #/* validation: set elem to error condition red */
  setError = (e) ->
    elemID = e.id
    if elemID
      chunks = elemID.split("_")
      return  if chunks.length < 2
      qid = $("#err_qa_" + chunks[1])
      if $(qid).length
        $(qid).addClass "validation-error"
        errID = $(qid).attr("id") + "err"
        span = "<span class=\"validation-advice\" id=\"" + errID + "\">Your forgot something!</span>"
        $(qid).append span  unless $("#" + errID).length
        $("#" + elemID).addClass "validation-error"
      else
        elemobj = $("#" + elemID)
        parent = elemobj.parent()
        parent.addClass "validation-error"
        elemobj.addClass "validation-error"
        errID = elemobj.attr("id") + "err"
        span = "<br /><span class=\"validation-advice\" id=\"" + errID + "\">Your forgot something! " + elemID + "</span>"
        parent.append span  unless $("#" + errID).length
        
  #/* validation: clear validation error */
  
  clearError = (e) ->
    elemID = e.id
    if elemID
      chunks = elemID.split("_")
      return  if chunks.length < 2
      qid = $("#err_qa_" + chunks[1])
      if $(qid).length
        $(qid).removeClass "validation-error"
        errID = $(qid).attr("id") + "err"
        $("#" + errID).remove()  if $("#" + errID).length
        $("#" + elemID).removeClass "validation-error"
      else
        elemobj = $("#" + elemID)
        parent = elemobj.parent()
        parent.removeClass "validation-error"
        elemobj.removeClass "validation-error"
        errID = elemobj.attr("id") + "err"
        $("#" + errID).remove()  if $("#" + errID).length
        
  #/* data behaviors */
  $("[data-behavior=\"toggle_other\"]").click (e) ->
    id = @id
    input_type = $("#" + id).attr("type").toLowerCase()
    divid = "other_" + id
    textid = "text_" + id
    if input_type is "radio"
      other_id = undefined
      other_text = undefined
      input_name = $("#" + id).attr("name")
      input_name = input_name
      selt = "input[name=\"" + input_name + "\"]:radio"
      radio_group = $(selt)
      i = 0

      while i < radio_group.length
        other_id = "other_" + radio_group[i].id
        other_text = "text_" + radio_group[i].id
        if $("#" + other_id)
          if radio_group[i].checked
            if $("#" + other_id).length
              $("#" + other_id).show()
              $("#" + other_text).attr "disabled", false
          else
            if $("#" + other_id).length
              $("#" + other_id).hide()
              $("#" + other_text).attr "value", ""
              $("#" + other_text).attr "disabled", true
        i++
    else
      if @checked
        $("#" + divid).show()
        $("#" + textid).attr "disabled", false
      else
        $("#" + divid).hide()
        $("#" + textid).attr "value", ""
        $("#" + textid).attr "disabled", true

  $("[data-behavior=\"toggle_other_sel\"]").change (e) ->
    id = @id
    seld = $("#" + id + " option")
    divid = "other_" + id + "_"
    textid = "text_" + id + "_"
    seld.each ->
      odivid = divid + $(this).val()
      otextid = textid + $(this).val()
      if $("#" + odivid).length
        if $(this).attr("selected")
          $("#" + odivid).show()
          $("#" + otextid).attr "disabled", false
        else
          $("#" + odivid).hide()
          $("#" + otextid).attr "value", ""
          $("#" + otextid).attr "disabled", true

  $("[data-behavior=\"validateRequired\"]").submit ->
    validateRequired()