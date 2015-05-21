
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

  var fadeEffect = new SequenceEffect([buildFadeOut(previous), buildFadeIn(current)]);
  var allEffects = [scaleEffect, fadeEffect];

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
    delay: -1000,
    fill: 'backwards',
    easing: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)'
  });
}

function buildFadeOut(target) {
  var angle = Math.pow((Math.random() * 16) - 6, 3);
  var offset = (Math.random() * 20) - 10;
  var transform =
      'translate(' + offset + 'em, 20em) ' +
      'rotate(' + angle + 'deg) ' +
      'scale(0)';
  var steps = [
    {visibility: 'visible', opacity: 1, transform: 'none'},
    {visibility: 'visible', opacity: 0, transform: transform}
  ];
  return new KeyframeEffect(target, steps, {
    duration: 1500,
    easing: 'ease-in'
  });
}

window.addEventListener('load', function() {
  var icon = document.querySelector('.icon');

  var steps = [
    {color: 'hsl(206, 46%, 89%)', transform: 'scale(0.5)'},
    {color: 'hsl(13, 79%, 96%)', transform: 'scale(2)'},
    {color: 'red', transform: 'scale(1)'}
  ];

  var timing = {duration: 1, fill: 'both', easing: 'ease-in-out'};
  var anim = icon.animate(steps, timing);
  anim.pause();  // never play this animation forward

  function updatePlayer() {
    var top = window.scrollY;
    var height = document.body.scrollHeight - window.innerHeight;
    anim.currentTime = top / height;
  }
  updatePlayer();
  window.addEventListener('scroll', updatePlayer);
});