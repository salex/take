$(document).ready(function() {
  $('[data-behavior="toggle_other"]').click(function(e) {
    var id = this.id
    var input_type = $('#'+id).attr("type").toLowerCase()
	
    var divid = "other_"+id
    var textid = "text_"+id
    if (input_type == 'radio') {
	    var other_id, other_text
		var input_name = $('#'+id).attr("name")
		input_name = input_name
		//var input_form = $(id).form
		var selt = 'input[name="'+input_name+'"]:radio'
		var radio_group = $(selt)
		//alert(radio_group.length+"rg"+selt)
		for (var i = 0; i < radio_group.length; i++) {
			//alert(radio_group[i].id + " - " + radio_group[i].checked)
			other_id = "other_"+radio_group[i].id 
			other_text = "text_"+radio_group[i].id
			if ($("#"+other_id)) {
				if (radio_group[i].checked) {
					if ($("#"+other_id).length) {
						$("#"+other_id).show()
						$("#"+other_text).attr("disabled",false)
					};
				} else {
					if ($("#"+other_id).length) {
						$("#"+other_id).hide()
						$("#"+other_text).attr("value","")
						$("#"+other_text).attr("disabled",true)
					};
				};
			};
		};

	} else {
	
        if (this.checked) {
            $('#'+divid).show()
            $('#'+textid).attr('disabled',false)
        }else{
            $('#'+divid).hide()
            $('#'+textid).attr('value',"")
            $('#'+textid).attr('disabled',true)
        };
    };
  });
  
  $('[data-behavior="toggle_other_sel"]').change(function(e) {
    var id = this.id
    var seld = $("#"+id+" option")
    var divid = "other_"+id+"_"
    var textid = "text_"+id+"_"
    seld.each(function() {
       var odivid = divid + $(this).val();
       var otextid = textid + $(this).val();
       if ($("#"+odivid).length) {
           if ($(this).attr("selected")) {
               $('#'+odivid).show()
               $('#'+otextid).attr('disabled',false)
           }else{
               $('#'+odivid).hide()
               $('#'+otextid).attr('value',"")
               $('#'+otextid).attr('disabled',true)
           };
       };
    });
  });
  
    $('[data-behavior="validateRequired"]').submit(function() {
        return( validateRequired());
    });

  
});

function esc(mySel) { 
	return mySel.replace(/([:|\.\]\[])/g,'\\$1');
}

function validateRequired(){
	var formElements = $(".required, .required-one");
	var valid = true;
	//formElements.each(function(elm) {
	for (var i = 0; i < formElements.length; i++) {
		var elm = formElements[i]
			var type = elm.type.toLowerCase();
			var node = elm.nodeName.toLowerCase();
			var elm_valid = true 
			if (node == 'input') {
					var type = elm.type.toLowerCase();
					if (type == 'text' || type == 'password') {
							elm_valid = !isEmpty(elm)
							elm_valid ? clearError(elm) : setError(elm)
							valid = valid && elm_valid
					} else if (type == 'radio' || type == 'checkbox') {
							elm_valid = isChecked(elm)
							elm_valid ? clearError(elm) : setError(elm)
							valid = valid && elm_valid
					}
			} else if (node == 'textarea') {
					elm_valid = !isEmpty(elm)
					elm_valid ? clearError(elm) : setError(elm)
					valid = valid && elm_valid
					
			} else if (node == 'select') {				
					elm_valid = isSelected(elm)
					elm_valid ? clearError(elm) : setError(elm)
					valid = valid && elm_valid
					
			} else {

			}

	};
	var test = valid
	if (!valid) {
		return(false)
	 };
	return(true)
}

function isEmpty(e) {
	var v = e.value;
	return((v == null) || (v.length == 0));
}

function isSelected(e) {
	return e.options ? e.selectedIndex > 0: false;
}

function isChecked(e) {
	var ename = esc(e.name)
	var ckd = $('input[name="'+ename+'"]:checked')
	return (ckd.size() > 0)

}

function setError(e) {
	var elemID = e.id
	
	if (elemID) {
		var chunks = elemID.split("_")
		if (chunks.length < 2) {
				return
		};
		
		var qid = $("#err_qa_" + chunks[1])
		if ($(qid).length) {
		    
			$(qid).addClass('validation-error')
			errID = $(qid).attr("id") + "err"
			span = '<span class="validation-advice" id="' + errID + '">Your forgot something!</span>'
			
			if (!$("#"+errID).length) {
					$(qid).append(span)
			}
			$("#"+elemID).addClass('validation-error')
			
			
		}else{
			elemobj = $("#"+elemID)
			parent = elemobj.parent()
			parent.addClass('validation-error')
			elemobj.addClass('validation-error')
			
			errID = elemobj.attr("id") + "err"
			span = '<br /><span class="validation-advice" id="' + errID + '">Your forgot something! '+elemID+'</span>'
			if (!$("#"+errID).length) {
				parent.append(span)
			}
			
			
		}
	}
}

function clearError(e) {
	var elemID = e.id
	if (elemID) {
		var chunks = elemID.split("_")
		if (chunks.length < 2) {
				return
		};
		var qid = $("#err_qa_" + chunks[1])
		if ($(qid).length) {
			$(qid).removeClass('validation-error')
			
			errID = $(qid).attr("id") + "err"
			if ($("#"+errID).length) {
					$("#"+errID).remove()
			}
			$("#"+elemID).removeClass('validation-error')
			
		}else{
			elemobj = $("#"+elemID)
			parent = elemobj.parent()
			parent.removeClass('validation-error')
			elemobj.removeClass('validation-error')
			errID = elemobj.attr("id") + "err"
			if ($("#"+errID).length) {
					$("#"+errID).remove()
			}
			
		}
	}
}
