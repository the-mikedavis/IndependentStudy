# High Striker

![High Striker](assets/high_striker.jpg)

Remember this pain in the ass? Why not bring it back for computers?

![Classic](assets/balloon_striker.jpg)

This is the most basic version possible, and it's based on sound inputs. The
user can jump on, or strike, a platform to trip the trigger and fire the puck
up. How high the puck goes is directly related to the strength of the sound.

What happens if you put it in a really loud room though? And what about the
sound of people speaking?

Hopefully, if the microphone is inside a platform, you won't have to worry
about talking noise too much. Loud rooms though do present a challenge which
is solved with a **threshold** for the trigger. The trigger threshold relies
on **linear smoothing** which essentially takes a weighted average of the
noises it's heard recently to make a baseline.
