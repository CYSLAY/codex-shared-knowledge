# Design workgroups

Read only the sections for the deliverables in the current task. Verify that every named skill is actually available, then read its complete `SKILL.md` before invoking it.

## Website and UI

Lead route:

```text
brainstorming when direction is unsettled
-> design-taste-frontend
-> applicable specialists
-> live-page acceptance
```

- `apple-design`: physical motion, gestures, sheets, depth, translucent materials, typography refinement, or Apple-style interaction principles.
- `animate`: ordinary UI motion and transitions that need deliberate implementation.
- `gsap-core` + `gsap-timeline`: complex animation sequencing.
- `gsap-scrolltrigger`: scroll narratives, scrubbed motion, parallax, or pinned sections.
- `gsap-react`: React or Next.js lifecycle-safe GSAP implementation.
- `gsap-performance`: production performance work whenever a substantial GSAP system is used.
- `web-design-guidelines`: audit an existing interface, especially hierarchy, states, consistency, and accessibility.
- `review-animations`: use only when the user explicitly requests motion critique or its current invocation policy otherwise permits it.

Prefer CSS for simple state transitions. Do not add GSAP merely to increase the number of skills used.

## Presentations

Lead route:

```text
brainstorming when narrative or visual direction is unsettled
-> ppt-master
-> presentation artifact authoring and render verification
-> slide acceptance
```

- Add `imagegen` only when new raster visuals or permitted generative edits materially improve the deck.
- Apply `apple-design` principles only when that visual language matches the audience and message; it is not a generic premium-style switch.
- For self-running or narrated output, validate the deck first and then hand off to the video workgroup.
- Verify editable structure, overflow, typography, charts, images, animation behavior, and actual rendered pages as applicable.

## Images

Select the production method before the visual tool:

- new raster image or permitted generative transformation: `imagegen`;
- no-regeneration edit: deterministic pixel operations such as masks, cloning, repair, curves, levels, and local exposure; prohibit `imagegen`;
- diagram, chart, or structured graphic whose editability matters: code-native, vector, or visualization workflow.

Compare with the original when editing. Preserve dimensions, resolution, and all regions outside the intended mask unless the user asks otherwise.

## Video

Lead routes:

- `video-use`: editing, transcription, cuts, grading, overlays, subtitles, talking heads, montages, and general production;
- `video-shotcraft`: cinematic product films using real website or interface captures, camera motion, beat-synced cuts, and sound design;
- `manim-video`: mathematical, algorithmic, scientific, or technical explanation through programmatic animation.

Use the image or website workgroup to create source assets when needed. Watch the complete exported result and check duration, framing, audio, subtitles, transitions, and missing or corrupt ranges.

## Cross-media

Use one shared target effect and one final acceptance pass. Let each workgroup own its artifact, for example:

```text
presentation workgroup
-> image assets
-> video adaptation
-> combined acceptance
```

Do not make each workgroup independently redefine the brand or narrative.
