(function () {
    var openButtons = document.querySelectorAll('[data-open-modal]');
    var closeButtons = document.querySelectorAll('[data-close-modal]');

    function openModal(modalId) {
        var modal = document.getElementById(modalId);
        if (!modal) {
            return;
        }
        modal.hidden = false;
        document.body.classList.add('modal-open');
    }

    function closeModal(element) {
        var modal = element.closest('.modal');
        if (!modal) {
            return;
        }
        modal.hidden = true;

        var anyOpen = document.querySelector('.modal:not([hidden])');
        if (!anyOpen) {
            document.body.classList.remove('modal-open');
        }
    }

    openButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            var modalId = button.getAttribute('data-open-modal');
            if (modalId) {
                openModal(modalId);
            }
        });
    });

    closeButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            closeModal(button);
        });
    });

    document.addEventListener('keydown', function (event) {
        if (event.key !== 'Escape') {
            return;
        }
        var opened = document.querySelectorAll('.modal:not([hidden])');
        opened.forEach(function (modal) {
            modal.hidden = true;
        });
        document.body.classList.remove('modal-open');
    });

    setTimeout(function () {
        var flashes = document.querySelectorAll('.flash');
        for (var i = 0; i < flashes.length; i++) {
            flashes[i].style.display = 'none';
        }
    }, 3000);
})();
