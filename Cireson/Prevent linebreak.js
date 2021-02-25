// Add char counter to text fields on ROs
$(document).ready(function (){
	console.log("Loading custom_TextfieldInRO.js");
  if (document.URL.indexOf("ServiceCatalog/RequestOffering") > -1) { // Only worry about RO forms
    // Get all text boxes
    var textAreas = $('[id^=textArea]');

    for (var i = 0; i < textAreas.length; i++) {

      // We need both obj and element
      var thisTextAreaObj = $(textAreas[i]);
      var thisTextAreaElm = textAreas[i];
      
      // if Limit String Length is not set on RO, the maxLength attr is missing,
      // so assume the class property is the standard max 256 chars, and treat
      // it as a single line text prompt
      if(thisTextAreaElm.maxLength == -1)
        thisTextAreaElm.maxLength = 199;

      var maxLength = thisTextAreaElm.maxLength;
      
      // Only add counter to > 1-line prompts
      if(maxLength > 199) {

        // Create a div for holding the remaing char count
        thisTextAreaObj.after('<div id="charCountOf'+thisTextAreaElm.id+'" align="right">'+maxLength+'</div>');

        // Listen in on the key up event
        thisTextAreaObj.on('keyup', function() {
          // Update text in div
          $('#charCountOf' + this.id).text(this.maxLength - this.value.length);
        });
      }

      // If the lenght is less than 199, we have a single line text prompt, so
      // disable Enter key event
      else if(maxLength > -1) {
        thisTextAreaObj.keydown(function(event){if(event.which == 13 ){event.preventDefault();}}).keyup(function(event){if(event.which == 13 ){event.preventDefault();}});
      }
    }
  }
});
