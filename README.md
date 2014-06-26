###Flow Fields
steering forces from the grid

________________

####References:
- [Flow Fields, Feedback Loops, and Memory Allocation (or, How I Learned to Love The Starry Dynamo in the Machinery of Night)](http://itp.nyu.edu/~js5346/jayblog/2012/04/27/flow-fields-feedback-loops-and-memory-allocation-or-how-i-learned-to-love-the-starry-dynamo-in-the-machinery-of-night/) - my blog post about flow field possibilities

####Types of Fields
- gravity
- flow map
- closest point
- userID
- edge
- Cellular Automata
- Recursive??
- Autonomous, Lifelike, and Improvisational? (with their own 'behavior force'?)

####Keywords:
- tessellation structures
- Diffusion-Limited Aggregation of Dendritit Growth
- Multi-phase fluids
- Lattice Gasses 
- Reaction-Diffusion Systems

________________________

###Exchange with Shiffman re Flow Fields:
- Shiffman's response:

```text
Hi Jason,

Thanks for this e-mail, really interesting stuff! I wonder if you
should consider looking at CA [Cellular Automata] rules and applying them to flow fields,
i.e. a vector in a flow field’s state is its magnitude and/or
direction and its new state at each generation would be calculated as
a function of its neighbors.

This is an interesting idea for a Nature of Code exercise for my CA
chapter in fact.

I’ll think about this more and look forward to your thesis presentation!

Let me know if there’s anything else I can do to help,
Dan [Shiffman] 
```

- email to Shiffman re recursive flow fields and such:
>

```text
As always, I greatly appreciate your willingness to so quickly and thoroughly respond to what must be an unending flow of programming related questions.

New developments in my paradigm, projects, and programming skills have lead to this email. Writing you has helped me flush out some new ideas, some of which I was not aware of until I reread what I had written you. In this respect, some of what’s written here was just a thought exercise that I’ve left for you to read at your discretion.

And congratulations on your recent recognition as super bad ass teacher.

re: emergent / recursive Flow Fields

[short version]

my setup:
1) flow field informs particles that are projected onto massage table. (field informed by depth, movement, light, etc)
2) separate computer/kinect provides video goggle image that the client sees of themselves on the massage table. (particles for this image derived from viewed pixel information. Flow field informed by depth, movement, light as well). Discovery: image viewed in goggles can be modulated with patterns of light reflected off the client, patterns which are themselves informed by the first flow field. Thus, one flow field modulates another flow field.

Naturally, my mind was drawn into the singularity of flow field feedback loops.

I’m interested in:

a) feedback loops and recursion in flow fields (as opposed to video feedback loops represented as a flow field). Does it even make sense to talk about Flow Fields that call themselves? Or flow fields that reflect each other? If so, what about runaway feedback loops in fields derived from motion and light but expressed as depth?

b) life-like and seemingly improvisational behavior between vectors in a flow field and between multiple flow fields in a system, which are themselves informed by diverse information sources. (eg, depth and light flow fields combine to form an emergent single field where particles move down an elevation gradient but up an illumination gradient, such that bright spots create mountains or valleys by amplifying current topography, etc etct).

respectfully,

jason stephens

ps.[more details, if you'd like]
I just saw the Starry Night flow field. I imagine something similar for the massage client using video goggles to see a bright light on their chest that resembles the moon in the Starry Night flow field. The light comes from a swarm of bright particles that are actually projected onto the client from the video projector. These particles circle around the highest plateaus of the client’s body via a depth informed flow field. Pixel info from the image, as seen by the client in the video goggle view, is then used as the particle system (Starry Night style). Meahwhile, a secondary kinect / computer creates a depth/light informed flow field to control the new particle system made up of, and visible to, the client, such that bright pixels are extruded into z dimension above the client’s body. What would start out as bright light projected onto the client in the form of, say, a white ellipse with a radial gradient, would, for the client, look like a sphere, textured with the client’s image, extending into the space beyond the client’s bodily borders at a distance relative to the radial gradient of the projected ellipse.

pps.[even more details]

I’m wanting to explore emergent flow patterns between flow fields that are aware of, and capable of responding to, other flow fields. Mirror neurons in flow patterns that allow entire flow fields to be recreated inside a flow field?

Recursive FlowFields? (eg Recursive FlowField get(piece of yourself, apply (add / subtract that piece to yourself). let the new Vectors determine the movement of this new piece of yourself through yourself, while you retain original vectors such that sufficient continuity remains betweens the hierarchies without falling into reptition or dropping off into random()). I see how I can create a feedback loop with video cameras and convert this into a flow field, but visible light has the luxury of being visible. Projecting the depthImage onto the massage table was kinda of like looking into a mirror and not seeing a reflection, the otherwise infinite video feedback loop stopped even though a camera informed the projected light. I could use an RGB camera to see the depthImage, but this wouldn’t be a feedback loop based on depth, it would be based on a visible representation of depth. How do I remain inside the realm of a particular form of information to produce the emergent organic patterns found in analog video feedback? I guess that’s exactly what flocking behaviors are, actually. Situational/behavioral based feedback loops expressed as emergent group dynamics. Creating life-like and seemingly improvisational behaviors in flow fields? Every vector aware of every other vector? such that a change changes the internal state, and subsequent behavior of, all the others agents. What does flocking look like if change of location is not an option?

Any and all feedback or pointers to related info would be greatly appreciated:

respectfully,

jason stephens
```

