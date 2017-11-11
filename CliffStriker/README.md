# Cliff Striker

Make a loud noise to launch a tight-roping guy off his tightrope, down a cliff,
bounce off a net, and fly high into the sky.

This is the most technical of the high-striker bunches. These are its cool
components:

- wind
- sprite animation
- bouncing physics
- screen shaking

#### Wind

The sketch has a weather vane which shows the current wind direction. The wind
pushes the character slightly based on its direction. It does this by
modifying the object's `PVector location`. The ability to change direction is
made possible by _event-based_ animation. Instead of animating based on the
current frame, frames are added to a variable each time an event is called.

#### Sprite animation

The sprite is animated in a more classic, frame based animation. Position and
sprite image is based on the current frame modulus. Every 60 frames the image
changes and every 120 frames the position changes.

#### Bouncing physics

The sprite ("character") has `PVector`s for location, velocity, and
acceleration. Falling is caused by adding a small acceleration downward.
Bouncing is a vertical velocity reflection. The `y` component is multiplied
by `-1`.

#### Screen Shaking

When the guy falls off the tight-rope, the screen shakes. This is actually a
very simple animation. The screen is captured as an image, and that image
then covers the canvas at a random offset. Done quickly over a few frames makes
a shake-like animation.
