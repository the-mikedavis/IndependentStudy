# Creating a drawing app with Unity and Leap Motion

Imagine drawing with your bare hands. With Leap Motion, you can! Leap Motion
is a controller that tracks your hands' and arms' positions without having
to wear or pick up anything. The result is intuitive and fun to use.

N.B. this has been adapted to use no VR headset for the purpose of wide
audience.

## How to get started

You'll need a few things:

- The latest build of Unity
- A leap motion controller
- The leap motion [Unity SDK](https://developer.leapmotion.com/unity/#116)
    - also get the Interactive Engine Modules on that page

Once you have those, you're good to go. Open up Unity. Import the SDK into
Assets.

Under Assets, navigate to `/Assets/LeapMotion/Core/Examples`. Open up
`Leap Hands Demo (Desktop).unity` and hit play (top middle of the editor).
Try out the hands and see how they feel.

## Creating the drawing app

Now that you have the hands demo open, save it as something new. We'll be
using this project as a base for the drawing app. Go to
`File > Save Scene as...` and choose a new name.

Create a material by right-clicking in assets and going to
`Create > Material`. Color it whatever you want and name it Line Material.
(N.B. the name doesn't matter.)

Create an empty game object by right-clicking in the hierarchy tab and
selecting `Create Empty`. Name it "Pinch Draw" (name does not really matter).
Go to `/Assets/LeapMotionModules/DetectionExamples/Scripts` and look (briefly)
at `PinchDraw`. Drag that script onto the game object you just created
(Pinch Draw).

Check out the fields of that new script. The first should be `size`. Set
that to 2 (one for each hand). Go to the circle next to the `Material` field
and get the `Line Material` Material we created first. Set the draw color
to whatever.

Now look at the Hierarchy pane. There should be a `Camera` object in it.
Open up the arrow and there's a `LeapHandController` inside. This is what
contains the hands, and it holds all the scripts which give the hands their
functionality. Drag the `LeapHandController` one level out of the Hierarchy
so that it's on the same level as `Camera` and `Pinch Draw`. This will allow
you to move around the Camera object so that you can get the view that suits
you best. Try out different angles and see what you like best.

When you've found the optimal camera angle, it's time to mess with the hands.
Create two new empty game objects in the Hierarchy and call them
`Pinch Detect Left` and `Pinch Detect Right`. Go to
`/Assets/LeapMotion/Core/Scripts/DetectionUtilities` and look at the
`PinchDetector`. This is the script which tells unity that a pinch has
occurred, is occurring, or has ended. Drag and drop this script onto
`Pinch Detect Left` and `Pinch Detect Right`. In the Inspector pane,
find the `Hand Model` field. Hit the circle and select the appropriate
CapsuleHand\_(L/R) from the scene. This binds the pinch detector to that hand.

Now go back to the `Pinch Draw` object. Look at the Element 0 and Element 1
fields. Hit the circles and attach the pinch detection objects we've just
created.

Now you can draw! Try it out!
