(function () {
    var menuRoots = document.querySelectorAll('[data-menu]');

    function closeAllMenus(exceptMenu) {
        menuRoots.forEach(function (root) {
            if (exceptMenu && root === exceptMenu) {
                return;
            }
            var panel = root.querySelector('[data-menu-panel]');
            if (panel) {
                panel.classList.remove('is-open');
            }
        });
    }

    menuRoots.forEach(function (menuRoot) {
        var toggle = menuRoot.querySelector('[data-menu-toggle]');
        var panel = menuRoot.querySelector('[data-menu-panel]');
        if (!toggle || !panel) {
            return;
        }
        toggle.addEventListener('click', function (event) {
            event.stopPropagation();
            var willOpen = !panel.classList.contains('is-open');
            closeAllMenus(menuRoot);
            if (willOpen) {
                panel.classList.add('is-open');
            } else {
                panel.classList.remove('is-open');
            }
        });
    });

    document.addEventListener('click', function () {
        closeAllMenus(null);
    });
})();
