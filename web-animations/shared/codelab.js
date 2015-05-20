/*
 * Copyright 2015 Google Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */


/**
 * @fileoverview Shared library for the Web Animations codelab.
 */

window.addEventListener('load', function() {
  var current = null;
  var header = document.querySelector('header');

  /**
   * Handler for hash update. This will make the <section> named with the
   * matching value from location.hash visible, and other sections hidden.
   * This will also mark the relevant link with the 'active' class, and call
   * through to the 'animateToSection' method (if available).
   */
  function updateVisibleSection() {
    var hash = '' + location.hash;
    var section;
    if (hash.length) {
      section = document.querySelector('section[name="' + hash.substr(1) + '"]');
    } else {
      section = document.querySelector('section');
    }
    if (!section) { return; }
    var link = header.querySelector('a[href="#' + section.getAttribute('name') + '"]');

    var previous = current;
    current = section;

    // Make the correct <section></section> visible.
    var all = document.querySelectorAll('section');
    for (var i = 0; i < all.length; ++i) {
      all[i].setAttribute('hidden', '');
    }
    current.removeAttribute('hidden');
    document.body.appendChild(current);  // append at end of doc for z-index

    // Set the .active tag on the chosen link.
    all = header.querySelectorAll('a');
    for (var i = 0; i < all.length; ++i) {
      all[i].className = '';
    }
    if (link) { link.className = 'active'; }

    // Call through to animate code, if available.
    if ('animateToSection' in window) {
      animateToSection(link, current, previous);
    }
  }

  // Trigger an initial hash update, and listen to changes.
  updateVisibleSection();
  window.addEventListener('hashchange', updateVisibleSection);
});


