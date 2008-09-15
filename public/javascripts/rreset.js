$().ready(function(){
  // Global Ajax setup
  $.ajaxSetup({ 
    'beforeSend': function(xhr) { xhr.setRequestHeader('Accept', 'text/javascript') },
    'dataType': 'script',
    'complete': Rreset.setup_remote_forms,
    'error': function() { alert("We're sorry, something went wrong. Please refresh your browser and try again."); }
  });
});


var Rreset = {
  // The label (example: "Medium") of the currently loaded photo
  current_photo_label: null,
  
  // Loads the largest possible photo that will fit in the window
  // Resizes and animates in a new photo if one is already loaded
  load_largest_photo: function() {
    // Create an array out of the different photo sizes
    var sizes = Array();
    $.each(Rreset.Photo.sizes, function(){ sizes.push(this); })
    // Sort the sizes (largest width to smallest width)
    sizes.sort(function(a,b){ return b.width - a.width });
    
    // Determine the largest that can fit on the page
    for (var i = 0; i < sizes.length; i++) {
      if (sizes[i].width <= $(window).width() - 20 && sizes[i].height / 1.8 <= $(window).height()) {
        if (sizes[i].label != this.current_photo_label && this.current_photo_label != null) {
          // If the window was resized, animate the changing dimensions
          var animation_speed = 600;
          $('#script_photo').attr('src', sizes[i].source)
            .show()
            .animate({ 
            width: sizes[i].width, 
            height: sizes[i].height
          }, animation_speed);
          $('.photo_width').animate({ width: sizes[i].width }, animation_speed);
        } else {
          // If the photo is being loaded initally, don't animate, just set sizes
          $('#script_photo').attr({
            src:    sizes[i].source,
            width:  sizes[i].width, 
            height: sizes[i].height
          }).show();
          $('.photo_width').width(parseInt(sizes[i].width));
        }
        // Set the current label and break out of the loop
        this.current_photo_label = sizes[i].label;
        break;
      }
    }
  },
  // Adds a dash of ajax to forms with the class "remote"
  setup_remote_forms: function(){
    $('form.remote').submit(function(){
      $(this).find(':submit')
        .attr('disabled', 'disabled')
        .val('saving...');
      $.post($(this).attr('action'), $(this).serializeArray());
      return false;
    }).removeClass('remote').find(':submit').removeAttr('disabled');
  },
  
  add_keyboard_navigation_listener: function() {
    $(window).keydown(function(e){
      if (e.keyCode == 37 || e.which == 37) {
        if ($('#photo_prev')[0]) {
          window.location = $('#photo_prev').attr('href');
        }
      }
      if (e.keyCode == 39 || e.which == 39) {
        if ($('#photo_next')[0]) {
          window.location = $('#photo_next').attr('href');
        }
      }
    });
  },
  // Sets up the the photo page
  initialize_photo_page: function() {
    $(window).resize(Rreset.load_largest_photo).resize();
    Rreset.add_keyboard_navigation_listener();
    $('#show_license, #license').toggle();
  }
};