
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

  var scaleEffect = new KeyframeEffect(effectNode, scaleSteps, timing);

  var allEffects = [scaleEffect, buildFadeIn(current)];

  // Play all animations within this group.
  var groupEffect = new GroupEffect(allEffects);
  var anim = document.timeline.play(groupEffect);
  anim.addEventListener('finish', function() {
    header.style.backgroundColor = newColor;
    header.removeChild(effectNode);
  });
}

function buildFadeIn(target) {
  var steps = [
    {opacity: 0, transform: 'translate(0, 20em)'},
    {opacity: 1, transform: 'translate(0)'}
  ];
  return new KeyframeEffect(target, steps, {
    duration: 500,
    easing: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)'
  });
}
