
/**
 * Called when a new section has been loaded.
 *
 * @param {Element} link element corresponding to new section
 * @param {Element} current now visible <section>
 * @param {Element} previous previously visible <section>
 */
function animateToSection(link, current, previous) {
  var effectNode = document.createElement('div');
  effectNode.className = 'circleEffect';

  var bounds = link.getBoundingClientRect();
  effectNode.style.left = bounds.left + bounds.width / 2 + 'px';
  effectNode.style.top = bounds.top + bounds.height / 2 + 'px';

  var header = document.querySelector('header');
  header.appendChild(effectNode);

  var newColor = 'hsl(' + Math.round(Math.random() * 255) + ', 46%, 42%)';
  effectNode.style.background = newColor;

  var scaleSteps = [{transform: 'scale(0)'}, {transform: 'scale(1)'}];
  var timing = {duration: 2500, easing: 'ease-in-out'};

  var anim = effectNode.animate(scaleSteps, timing);
  anim.addEventListener('finish', function() {
    header.style.backgroundColor = newColor;
    header.removeChild(effectNode);
  });
}
