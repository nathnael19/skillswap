# Design System Strategy: The Curated Exchange

This design system is built to transform a standard utility app into a premium, editorial experience. We are moving away from the "app-as-a-tool" aesthetic toward "app-as-a-destination." By leaning into sophisticated tonal layering, intentional asymmetry, and high-end typography, we establish a sense of mastery and trust—essential for a community built on skill-sharing.

---

## 1. Creative North Star: "The Digital Curator"
The "Digital Curator" philosophy treats every user profile and skill-card as a piece of featured content. We reject the cluttered, boxy look of traditional marketplaces. Instead, we use expansive breathing room, overlapping elements, and a "paper-on-glass" layering logic. The goal is to make the user feel like they are browsing a high-end magazine, where the "Action Blue" (Primary) serves as the ink and the "Warm Amber" (Tertiary) acts as the highlighter for moments of human connection.

---

## 2. Color & Tonal Architecture
We utilize a sophisticated Material 3 palette, but we apply it with editorial restraint. 

### Palette Strategy
- **Primary (`#00647e`):** Our "Action Blue." It is authoritative yet inviting. Use this for the most critical paths.
- **Secondary (`#00687a`):** A subtle shift toward teal to provide depth in navigation and secondary actions.
- **Tertiary (`#825100`):** Our "Success Accent." This warm amber is reserved exclusively for "Matches," "Completion," and "Achievement." It represents the human warmth of a successful swap.

### The "No-Line" Rule
**Explicit Instruction:** Prohibit 1px solid borders for sectioning. 
Structure must be defined by background shifts. To separate a profile header from a skill list, transition from `surface` to `surface-container-low`. The eye should perceive change through value, not lines.

### Glass & Gradient Strategy
To elevate the "Modern" requirement, use the **Signature Glow**.
- **CTAs:** Apply a linear gradient from `primary` (#00647e) to `primary-container` (#227e9a) at a 135-degree angle. This adds "soul" and dimension.
- **Floating Navigation:** Use `surface_container_lowest` with an 80% opacity and a `24px` backdrop-blur to create a frosted glass effect that feels lightweight and integrated.

---

## 3. Typography: The Editorial Voice
We use a dual-typeface system to balance professional authority with approachable clarity.

- **The Voice (Manrope):** Used for `display` and `headline` scales. Manrope’s geometric yet warm curves provide a "modern-premium" feel. Use `headline-lg` (2rem) with tight letter-spacing (-0.02em) for profile names to create a signature look.
- **The Engine (Be Vietnam Pro):** Used for `title`, `body`, and `label`. It is optimized for high legibility in functional contexts like chat bubbles and scheduling forms.

**Hierarchy Tip:** Always pair a `headline-sm` title with a `label-md` in all-caps (tracking +5%) sitting *above* it to categorize content (e.g., "MARKETING • 5 MILES AWAY").

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows are a relic. This system uses **Tonal Stacking** to convey hierarchy.

- **The Layering Principle:** 
    1. Base: `surface` (#f9f9ff)
    2. Section: `surface-container-low` (#f1f3fe)
    3. Interactive Card: `surface-container-lowest` (#ffffff)
- **The "Ghost Border" Fallback:** If accessibility requires a container definition (e.g., in high-glare environments), use the `outline-variant` (#c1c6d7) at **15% opacity**. It should be felt, not seen.
- **Ambient Shadows:** For the "Swipe" cards, use a shadow with a 40px blur, 0px offset, and 6% opacity of the `on-surface` color. It should look like a soft glow of light, not a drop shadow.

---

## 5. Components

### The Discovery "Swipe" Card
- **Structure:** Use `xl` (1.5rem) corner radius. The card should be `surface-container-lowest`. 
- **Detail:** Use an image mask with a subtle 5% inner-gradient overlay at the bottom to ensure the `title-lg` text remains legible. 
- **Action:** No borders. The "Match" button should use the `tertiary` (#825100) color with a soft ambient shadow.

### Form Fields & Scheduling
- **Visuals:** Use "Floating" style inputs. No bottom line. Instead, use a `surface-container-high` background with a `sm` (0.25rem) radius.
- **State:** On focus, the background transitions to `surface-container-lowest` with a 1px `primary` ghost border (20% opacity).

### Friendly Chat Bubbles
- **Sender:** `primary` color, `lg` (1rem) radius, but the bottom-right corner is `sm` (0.25rem).
- **Receiver:** `surface-container-highest`, all corners `lg`. 
- **Spacing:** Use 12px vertical spacing between different speakers, but 4px between consecutive bubbles from the same speaker.

### Buttons
- **Primary:** Gradient (`primary` to `primary-container`), `full` (9999px) radius for an "action-pill" look.
- **Secondary:** Transparent background with a `primary` text color. No border.
- **Tertiary:** `tertiary-container` background with `on-tertiary-container` text for "Match" moments.

---

## 6. Do’s and Don’ts

### Do
- **Use Asymmetric White Space:** Give more padding to the top of a header than the bottom to create a "gallery" feel.
- **Layer with Intent:** Place a `primary-fixed-dim` chip on a `surface-container-highest` background for high-contrast tag recognition.
- **Embrace Roundedness:** Use the `xl` (1.5rem) radius for major containers to maintain the "approachable" brand promise.

### Don’t
- **Don’t use 100% Black:** Never use #000000. Use `on-surface` (#181c23) for text to maintain the sophisticated, soft-black editorial look.
- **Don’t use Dividers:** Avoid horizontal rules `<hr>`. Use an 8px or 16px gap from the spacing scale or a subtle background color shift.
- **Don’t Over-Shadow:** If more than two elements on a screen have shadows, the hierarchy is broken. Use tonal shifts instead.