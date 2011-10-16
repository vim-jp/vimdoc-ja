$(function() {
    // Mark an item of current page in <nav>.
    var name = location.pathname.match(/[^/]+\.html/);
    name = name ? name[0] : 'index.html';
    var tag = $('nav a[href="' + name + '"]');
    if (tag) {
        tag.addClass('CurrentPage');
    }
})
// vim:set ts=8 sts=4 sw=4 tw=0 et:
