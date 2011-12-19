# TTTTTTTTTTTTTTTTTTT Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.


$(document).ready ->

  $('[data-behavior="edit_contains"]').live("click",  -> 
    $("#"+this.id+"_div").show())

  $('[data-behavior="edit_numeric"]').live("click", -> 
    $("#"+this.id+"_div").show())

  $('[data-behavior="contains_cancel"]').live("click", ->
    seq = get_seq(this.id)
    $("#eval_"+seq+"_div").hide())

  $('[data-behavior="numeric_cancel"]').live("click", ->
    seq = get_seq(this.id)
    $("#eval_"+seq+"_div").hide())

  $('[data-behavior="contains_update"]').live("click", ->
    update_contains(this.id))
      
  $('[data-behavior="numeric_update"]').live("click", ->
    update_numeric(this.id))

  update_contains = (id) ->
    key = get_seq_base(id)
    matchKey = key + "_match"
    partialKey = key + "_partial"
    match = $("."+ matchKey)
    partial = $("."+partialKey)
    match_section = format_match(match)
    partial_section = format_partial(partial)
    seq = get_seq(id)
    first = "question_answers_attributes_0_text_eval"
    first = first.replace("0",seq - 1)
    if partial_section == ""
      $("#"+first).val(match_section)
    else
      $("#"+first).val(match_section+"::"+partial_section)
    $("#eval_"+seq+"_div").hide()
    
  format_match = (matches) ->
    result = new Array()
    for match in matches
      if match.value != ""
        value = match.value
        id = match.id
        or_id = id.replace("contain_words", "contain_or")
        not_id = id.replace("contain_words", "contain_not")
        x = $("#"+or_id).prop('checked')
        y = $("#"+not_id).prop('checked')
        if x
          if value.indexOf("|") < 0
            value = value.replace( /\s+/g, ' ' )
            tmp = value.split(" ");
            value = "(" + tmp.join("|") + ")"
          else
            value = "(" + value + ")"
            
        if y
          value = "!" + value
        result.push(value)
    return(result.join("&"))
    
  format_partial = (partials) ->
    result = new Array()
    for partial in partials
      if partial.value != ""
        value = partial.value
        id = partial.id
        or_id = id.replace("partial_words", "partial_or")
        not_id = id.replace("partial_words", "partial_not")
        perc_id = id.replace("partial_words", "partial_perc")
        x = $("#"+or_id).prop('checked')
        y = $("#"+not_id).prop('checked')
        perc = $("#"+perc_id).val()
        if perc == "" then perc = 0
        if x
          if value.indexOf("|") < 0
            value = value.replace( /\s+/g, ' ' )
            tmp = value.split(" ");
            value = "(" + tmp.join("|") + ")"
          else
            value = "(" + value + ")"
        if y
          value = "!" + value
        value += ">>#{perc}"
        result.push(value)
    return(result.join("&"))
    

  update_numeric = (id) ->
    seq = get_seq(id)
    #deltas = $("."+id+"_delta")
    matchKey = "#numeric_match_"+seq
    nvalue = $(matchKey).val()
    key = get_seq_base(id)
    deltaKey = key + "_delta"
    deltas = $("."+ deltaKey)
    result = new Array()
    for delta in deltas
      if delta.value != ""
        value = delta.value
        id = delta.id
        perc_id = id.replace("numeric_delta", "numeric_perc")
        perc = $("#"+perc_id).val()
        if perc == "" then perc = 0
        value += ">>#{perc}"
        result.push(value)
    delta_section = result.join("::")
    first = "question_answers_attributes_0_text_eval"
    first = first.replace("0",seq - 1)
    if delta_section == ""
      $("#"+first).val(nvalue)
    else
      $("#"+first).val(nvalue+"::"+delta_section)
    $("#eval_"+seq+"_div").hide()

  get_seq = (id) ->
    t = id.split("_")
    return t[1]

  get_seq_base = (id) ->
    t = id.split("_")
    return t[0]+"_"+t[1]


