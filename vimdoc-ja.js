$(function() {
    // Mark an item of current page in <nav>.
    var tag = $('nav a[href="' + location.pathname + '"]');
    if (tag) {
        tag.addClass('CurrentPage');
    }
})
// vim:set ts=8 sts=4 sw=4 tw=0 et:
