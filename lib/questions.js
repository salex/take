$(document).ready(function() {
  var format_match, format_partial, get_seq, get_seq_base, update_contains, update_numeric;
  $('[data-behavior="edit_contains"]').live("click", function() {
    return $("#" + this.id + "_div").show();
  });
  $('[data-behavior="edit_numeric"]').live("click", function() {
    return $("#" + this.id + "_div").show();
  });
  $('[data-behavior="contains_cancel"]').live("click", function() {
    var seq;
    seq = get_seq(this.id);
    return $("#eval_" + seq + "_div").hide();
  });
  $('[data-behavior="numeric_cancel"]').live("click", function() {
    var seq;
    seq = get_seq(this.id);
    return $("#eval_" + seq + "_div").hide();
  });
  $('[data-behavior="contains_update"]').live("click", function() {
    return update_contains(this.id);
  });
  $('[data-behavior="numeric_update"]').live("click", function() {
    return update_numeric(this.id);
  });
  update_contains = function(id) {
    var first, key, match, matchKey, match_section, partial, partialKey, partial_section, seq;
    key = get_seq_base(id);
    matchKey = key + "_match";
    partialKey = key + "_partial";
    match = $("." + matchKey);
    partial = $("." + partialKey);
    match_section = format_match(match);
    partial_section = format_partial(partial);
    seq = get_seq(id);
    first = "question_answers_attributes_0_text_eval";
    first = first.replace("0", seq - 1);
    if (partial_section === "") {
      $("#" + first).val(match_section);
    } else {
      $("#" + first).val(match_section + "::" + partial_section);
    }
    return $("#eval_" + seq + "_div").hide();
  };
  format_match = function(matches) {
    var id, match, not_id, or_id, result, tmp, value, x, y, _i, _len;
    result = new Array();
    for (_i = 0, _len = matches.length; _i < _len; _i++) {
      match = matches[_i];
      if (match.value !== "") {
        value = match.value;
        id = match.id;
        or_id = id.replace("contain_words", "contain_or");
        not_id = id.replace("contain_words", "contain_not");
        x = $("#" + or_id).prop('checked');
        y = $("#" + not_id).prop('checked');
        if (x) {
          if (value.indexOf("|") < 0) {
            value = value.replace(/\s+/g, ' ');
            tmp = value.split(" ");
            value = "(" + tmp.join("|") + ")";
          } else {
            value = "(" + value + ")";
          }
        }
        if (y) {
          value = "!" + value;
        }
        result.push(value);
      }
    }
    return result.join("&");
  };
  format_partial = function(partials) {
    var id, not_id, or_id, partial, perc, perc_id, result, tmp, value, x, y, _i, _len;
    result = new Array();
    for (_i = 0, _len = partials.length; _i < _len; _i++) {
      partial = partials[_i];
      if (partial.value !== "") {
        value = partial.value;
        id = partial.id;
        or_id = id.replace("partial_words", "partial_or");
        not_id = id.replace("partial_words", "partial_not");
        perc_id = id.replace("partial_words", "partial_perc");
        x = $("#" + or_id).prop('checked');
        y = $("#" + not_id).prop('checked');
        perc = $("#" + perc_id).val();
        if (perc === "") {
          perc = 0;
        }
        if (x) {
          if (value.indexOf("|") < 0) {
            value = value.replace(/\s+/g, ' ');
            tmp = value.split(" ");
            value = "(" + tmp.join("|") + ")";
          } else {
            value = "(" + value + ")";
          }
        }
        if (y) {
          value = "!" + value;
        }
        value += ">>" + perc;
        result.push(value);
      }
    }
    return result.join("&");
  };
  update_numeric = function(id) {
    var delta, deltaKey, delta_section, deltas, first, key, matchKey, nvalue, perc, perc_id, result, seq, value, _i, _len;
    seq = get_seq(id);
    matchKey = "#numeric_match_" + seq;
    nvalue = $(matchKey).val();
    key = get_seq_base(id);
    deltaKey = key + "_delta";
    deltas = $("." + deltaKey);
    result = new Array();
    for (_i = 0, _len = deltas.length; _i < _len; _i++) {
      delta = deltas[_i];
      if (delta.value !== "") {
        value = delta.value;
        id = delta.id;
        perc_id = id.replace("numeric_delta", "numeric_perc");
        perc = $("#" + perc_id).val();
        if (perc === "") {
          perc = 0;
        }
        value += ">>" + perc;
        result.push(value);
      }
    }
    delta_section = result.join("::");
    first = "question_answers_attributes_0_text_eval";
    first = first.replace("0", seq - 1);
    if (delta_section === "") {
      $("#" + first).val(nvalue);
    } else {
      $("#" + first).val(nvalue + "::" + delta_section);
    }
    return $("#eval_" + seq + "_div").hide();
  };
  get_seq = function(id) {
    var t;
    t = id.split("_");
    return t[1];
  };
  return get_seq_base = function(id) {
    var t;
    t = id.split("_");
    return t[0] + "_" + t[1];
  };
});