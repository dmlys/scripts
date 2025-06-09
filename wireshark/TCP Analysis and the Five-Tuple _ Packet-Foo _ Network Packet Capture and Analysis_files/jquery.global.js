
jQuery(document).ready(function($) {

    // Search popup
    $('.search > .icon-search').click(function(){
       	$('.search_popup').slideDown('', function() {});
     	$('.search > .icon-search').toggleClass('active');
     	$('.search > .icon-remove').toggleClass('active');
    });

    $('.search > .icon-remove').click(function(){
       	$('.search_popup').slideUp('', function() {});
     	$('.search > .icon-search').toggleClass('active');
     	$('.search > .icon-remove').toggleClass('active');
    });

    // Mobile menu
    $('.menubutton').click(function(){
       	$('header nav').slideToggle('', function() {});
    });
	
	// Dropdown Menu
	if(jQuery().hoverIntent) {
		$('nav#primary-nav > ul > li').hoverIntent({
			over : function() { $(this).children('ul.sub-menu').fadeIn(); },
			out : function() { $(this).children('ul.sub-menu').fadeOut(); },
			timeout: 100
		});
	};
	
    // Responsive videos
    if (jQuery().fitVids) {
    	$("article").fitVids();
	};
	
    // Gallery slider
    if (jQuery().flexslider) {
	    $('.flexslider').flexslider({
	        animation: "slide",
	        smoothHeight: true,
            prevText: '<i class="fa fa-chevron-left"></i>',
            nextText: '<i class="fa fa-chevron-right"></i>'
	    });
	};

    // Comment form fields
    $('.comment-form-fields').slideDown();

    // Image popups
    $('.the-content a').each( function() {
        url = $(this).attr('href');

        if( url.match(/\.(jpeg|jpg|gif|png)$/) != null ) {
            $(this).magnificPopup({
                type: 'image',
                closeOnContentClick: true,
                mainClass: 'mfp-img-mobile',
                image: {
                    verticalFit: true
                }
            });
        }
    });

    // Slider Popups
    $('.flexslider .slides').each( function(){
        $(this).find('a').magnificPopup({
            type: 'image',
            tLoading: 'Loading image #%curr%...',
            mainClass: 'mfp-img-mobile',
            gallery: {
                enabled: true,
                navigateByImgClick: true,
                preload: [0,1] // Will preload 0 - before current, and 1 after the current image
            },
            image: {
                tError: '<a href="%url%">The image #%curr%</a> could not be loaded.',
                titleSrc: function(item) {
                    return item.el.find('.caption').text();
                }
            }
        });
    });
    
});