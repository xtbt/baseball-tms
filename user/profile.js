setTimeout(function () {
    var flashes = document.querySelectorAll('.flash');
    for (var i = 0; i < flashes.length; i++) {
        flashes[i].style.display = 'none';
    }
}, 3000);
