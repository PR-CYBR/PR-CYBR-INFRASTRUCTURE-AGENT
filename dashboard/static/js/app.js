(function () {
  const flashes = document.querySelectorAll('.flash-message');
  if (!flashes.length) return;
  setTimeout(() => {
    flashes.forEach((flash) => {
      flash.classList.add('flash-message--hide');
      setTimeout(() => flash.remove(), 500);
    });
  }, 4000);
})();
