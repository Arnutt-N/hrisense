---
name: HRiSENSE
description: Proactive workforce analytics dashboard for government HR teams
colors:
  primary: "#1e3a5f"
  primary-foreground: "#ffffff"
  secondary: "#f1f5f9"
  secondary-foreground: "#1e293b"
  accent: "#d4a574"
  accent-foreground: "#ffffff"
  background: "#f8fafc"
  foreground: "#0f172a"
  card: "#ffffff"
  card-foreground: "#0f172a"
  muted: "#f1f5f9"
  muted-foreground: "#64748b"
  destructive: "#dc2626"
  destructive-foreground: "#ffffff"
  border: "#e2e8f0"
  input: "#e2e8f0"
  ring: "#1e3a5f"
  risk-green: "#22c55e"
  risk-amber: "#f59e0b"
  risk-red: "#ef4444"
  risk-critical: "#991b1b"
typography:
  display:
    fontFamily: "Noto Sans Thai, Inter, system-ui, sans-serif"
    fontSize: "clamp(1.875rem, 4vw, 2.5rem)"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Noto Sans Thai, Inter, system-ui, sans-serif"
    fontSize: "1.875rem"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "-0.01em"
  title:
    fontFamily: "Noto Sans Thai, Inter, system-ui, sans-serif"
    fontSize: "1.25rem"
    fontWeight: 600
    lineHeight: 1.4
  body:
    fontFamily: "Noto Sans Thai, Inter, system-ui, sans-serif"
    fontSize: "0.9375rem"
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "Noto Sans Thai, Inter, system-ui, sans-serif"
    fontSize: "0.75rem"
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: "0.01em"
rounded:
  sm: "0.375rem"
  md: "0.5rem"
  lg: "0.625rem"
  xl: "0.75rem"
spacing:
  xs: "0.25rem"
  sm: "0.5rem"
  md: "1rem"
  lg: "1.5rem"
  xl: "2rem"
  2xl: "3rem"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.primary-foreground}"
    rounded: "{rounded.md}"
    padding: "0.625rem 1.25rem"
  button-primary-hover:
    backgroundColor: "#16294a"
  card-default:
    backgroundColor: "{colors.card}"
    textColor: "{colors.card-foreground}"
    rounded: "{rounded.lg}"
    padding: "1.5rem"
  badge-default:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.primary-foreground}"
    rounded: "9999px"
    padding: "0.25rem 0.625rem"
  badge-secondary:
    backgroundColor: "{colors.secondary}"
    textColor: "{colors.secondary-foreground}"
    rounded: "9999px"
    padding: "0.25rem 0.625rem"
  badge-destructive:
    backgroundColor: "{colors.destructive}"
    textColor: "{colors.destructive-foreground}"
    rounded: "9999px"
    padding: "0.25rem 0.625rem"
---

# Design System: HRiSENSE

## 1. Overview

**Creative North Star: "The Analyst's Dashboard"**

HRiSENSE is a professional workforce analytics interface that prioritizes clarity, precision, and actionable insight over decoration. The system serves HR managers and analysts who need to process complex personnel data quickly and make informed decisions. Every visual choice reinforces the feeling of a sophisticated analytical tool—like sitting at a well-organized command center where critical information is always visible and immediately legible.

The aesthetic balances measured warmth with professional restraint. While the interface handles serious government workforce data, it avoids the cold sterility of traditional enterprise software. Warm neutrals and carefully placed accent colors create an approachable yet authoritative presence. The typography—Noto Sans Thai throughout—ensures Thai text renders beautifully while maintaining the clean, modern feel of a contemporary analytics platform.

This system explicitly rejects generic SaaS dashboard templates, bureaucratic government software patterns, and consumer-app casualness. Every component earns its place through function, not decoration. Shadows are soft and purposeful, color is used strategically rather than liberally, and density is embraced where it serves the user's workflow.

**Key Characteristics:**
- **Professional restraint**: Color and decoration used sparingly; data and clarity take priority
- **Thai-first typography**: Noto Sans Thai as the sole typeface, optimized for Thai text rendering
- **Soft depth**: Subtle shadows create layering without heaviness; elevation responds to interaction
- **Semantic color system**: Risk indicators (green/amber/red/critical) follow consistent patterns across all surfaces
- **Measured warmth**: Neutral palette with subtle warm undertones prevents the interface from feeling sterile

## 2. Colors: The Measured Warmth Palette

The color system balances professional authority with approachable warmth. The primary blue conveys trust and analytical precision, while warm neutrals and strategic accent placement prevent the interface from feeling cold or sterile.

### Primary
- **Authority Blue** (#1e3a5f / hsl(215 52% 24%)): The dominant brand color, used for primary actions, active navigation states, and key interactive elements. This deep blue-gray carries authority without aggression, grounding the interface in professional credibility. Appears on buttons, active sidebar items, and critical headings.

### Secondary
- **Warm Sand** (#d4a574 / hsl(43 55% 54%)): The accent color, used sparingly to draw attention to secondary actions, highlights, and warm visual anchors. This muted gold-brown introduces measured warmth without overwhelming the cool primary palette. Reserved for ≤10% of any given screen.

### Neutral
- **Cool Cloud** (#f8fafc / hsl(210 20% 98%): Page background, providing a clean canvas that doesn't compete with content. The slight cool undertone keeps the interface feeling fresh.
- **Soft Slate** (#f1f5f9 / hsl(210 20% 96%): Secondary background for cards, sidebar, and muted sections. Creates subtle layering against the page background.
- **Deep Ink** (#0f172a / hsl(215 25% 15%): Primary text color, providing strong contrast against light backgrounds. High legibility for dense data and Thai text.
- **Muted Stone** (#64748b / hsl(215 15% 45%): Secondary text, labels, and placeholders. Used for supporting information that shouldn't compete with primary content.
- **Border Mist** (#e2e8f0 / hsl(214 20% 90%): Subtle borders and dividers. Defines boundaries without visual heaviness.

### Semantic
- **Risk Green** (#22c55e): Normal status, healthy metrics, positive trends
- **Risk Amber** (#f59e0b): Warning status, monitoring required, caution
- **Risk Red** (#ef4444): High risk, action needed, critical attention
- **Risk Critical** (#991b1b): Crisis level, immediate action required
- **Destructive Red** (#dc2626): Delete actions, errors, destructive operations

### Named Rules
**The One Voice Rule.** The primary blue carries ≤60% of interactive surfaces. The warm accent appears on ≤10% of any screen. Their restraint is the point—when everything is emphasized, nothing is.

**The Semantic Non-Negotiable.** Risk colors (green/amber/red/critical) follow identical patterns everywhere: same background tints, same text colors, same dot indicators. Consistency builds trust; variation creates confusion.

## 3. Typography: Single-Face Clarity

**Display Font:** Noto Sans Thai (with Inter, system-ui fallback)  
**Body Font:** Noto Sans Thai (with Inter, system-ui fallback)  
**Label/Mono Font:** Noto Sans Thai (with Inter, system-ui fallback)

**Character:** A single typeface carries the entire hierarchy, ensuring perfect harmony across Thai and English text. Noto Sans Thai's geometric clarity and excellent Thai rendering make it both professional and readable. Weight and size variations create hierarchy without introducing visual noise from multiple font families.

### Hierarchy
- **Display** (700, clamp(1.875rem, 4vw, 2.5rem), 1.2 line-height, -0.02em tracking): Page titles and major section headers. Fluid sizing ensures legibility across viewports while respecting the 6rem ceiling.
- **Headline** (700, 1.875rem, 1.3 line-height, -0.01em tracking): Card titles, modal headers, and prominent section labels. Slightly tighter tracking creates visual weight.
- **Title** (600, 1.25rem, 1.4 line-height): Subsection headers, card subheadings, and navigation labels. Medium weight provides clear hierarchy without overwhelming content.
- **Body** (400, 0.9375rem, 1.6 line-height): Primary content text, descriptions, and data. Generous line height accommodates Thai script's vertical complexity. Max line length 65–75ch for prose.
- **Label** (500, 0.75rem, 1.4 line-height, 0.01em tracking): Form labels, metadata, timestamps, and supporting information. Small but legible, with slight letter-spacing for clarity at reduced size.

### Named Rules
**The Single-Face Doctrine.** One typeface, many weights. Resist the urge to pair fonts—Noto Sans Thai's range handles every hierarchy need. Introducing a second family creates visual noise without functional benefit.

**The Thai-First Mandate.** All line heights, letter spacing, and sizing decisions prioritize Thai text rendering. Thai script's vertical complexity demands generous line height (≥1.4 for body). Test every hierarchy level with Thai content, not English.

## 4. Elevation: Soft Depth

The system uses soft, purposeful shadows to create layering and respond to interaction. Elevation is not decorative—it conveys state, hierarchy, and interactivity. Cards rest gently on the page; interactive elements lift slightly on hover; modals and dropdowns assert clear dominance over underlying content.

### Shadow Vocabulary
- **Resting** (`box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04)`): Default state for cards and containers. Subtle presence that defines boundaries without heaviness. Used at rest.
- **Lifted** (`box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08)`): Hover and focus states for interactive cards, buttons, and dropdowns. Signals interactivity and draws attention. Appears on hover.
- **Floating** (`box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12)`): Modals, dialogs, and dropdown menus. Clear separation from underlying content, asserting temporal dominance. Used for overlay elements.

### Named Rules
**The Purposeful Lift Rule.** Shadows appear only as a response to state: hover, focus, elevation, interaction. Static elements don't cast dramatic shadows. If it's not interactive or layered, it doesn't need a heavy shadow.

**The Soft Default.** All shadows use low opacity (0.04–0.12) and generous blur. Heavy, dark shadows feel aggressive and outdated. The goal is gentle separation, not dramatic contrast.

## 5. Components

### Buttons
- **Shape:** Gently rounded corners (0.5rem radius). Not pill-shaped, not sharp—professional restraint.
- **Primary:** Authority Blue background, white text, 0.625rem vertical / 1.25rem horizontal padding. Used for primary actions, form submissions, and key CTAs.
- **Hover / Focus:** Darkens to #16294a, lifts slightly (translateY(-1px)), shadow transitions to lifted state. 150ms ease-out transition.
- **Secondary:** Soft Slate background, Deep Ink text, same padding. Used for secondary actions, filters, and less prominent CTAs.
- **Ghost:** Transparent background, Deep Ink text, same padding. Hover reveals Soft Slate background. Used for tertiary actions and inline controls.

### Cards
- **Corner Style:** Rounded-lg (0.625rem radius). Consistent with the system's gentle rounding philosophy.
- **Background:** White (card color), creating clear separation from the Cool Cloud page background.
- **Shadow Strategy:** Resting shadow at rest, lifted shadow on hover for interactive cards. See Elevation section.
- **Border:** Subtle Border Mist border (1px) provides definition even without shadow.
- **Internal Padding:** 1.5rem (24px) standard. CardHeader uses 1.5rem with 0.375rem vertical gap between children. CardContent uses 1.5rem with 0 top padding when following CardHeader.

### Badges
- **Style:** Pill-shaped (9999px radius), 0.25rem vertical / 0.625rem horizontal padding, 0.75rem font size, 500 font weight.
- **Variants:**
  - **Default:** Primary Blue background, white text
  - **Secondary:** Soft Slate background, Deep Ink text
  - **Destructive:** Destructive Red background, white text
  - **Outline:** Transparent background, Deep Ink text, Border Mist border
- **Risk Badges:** Specialized variant with colored dot indicator + label. Green/amber/red/critical follow semantic color system. Thai labels: ปกติ / เฝ้าระวัง / เสี่ยงสูง / วิกฤต

### Inputs / Fields
- **Style:** 1px Border Mist border, white background, 0.5rem radius, 0.625rem vertical / 0.75rem horizontal padding.
- **Focus:** Ring color matches primary blue (2px offset ring). Border transitions to primary blue. 150ms ease transition.
- **Error:** Border transitions to destructive red. Error message appears below in destructive color, 0.75rem font size.
- **Disabled:** Soft Slate background, Muted Stone text, reduced opacity. Cursor not-allowed.

### Navigation (Sidebar)
- **Style:** Fixed-width sidebar (16rem / 256px), Soft Slate background, Border Mist right border.
- **Logo Area:** 4rem bottom padding, Border Mist bottom border. Logo icon in rounded-xl container with primary blue background at 10% opacity.
- **Nav Items:** 0.75rem vertical / 0.75rem horizontal padding, 0.5rem radius, 0.875rem font size. Icon + label layout with 0.75rem gap.
- **Active State:** Primary blue background at 10% opacity, primary blue text, 500 font weight.
- **Hover State:** Soft Slate background, Deep Ink text. 150ms ease transition.
- **Default State:** Muted Stone text, transparent background.

### KPI Cards
- **Style:** Card container with icon + value + subtitle layout. Icon in rounded-xl container with tinted background.
- **Layout:** Icon (5rem container) aligned top-right. Value in 1.875rem bold, title in 0.875rem muted, subtitle in 0.75rem muted.
- **Trend Indicator:** Optional up/down arrow with trend value. Green for positive, destructive for negative, muted for neutral.
- **Color Coding:** Icon container background can be tinted (bg-primary/10, bg-amber-50, bg-red-50, etc.) to reinforce the metric's semantic meaning.

## 6. Do's and Don'ts

### Do:
- **Do** use Noto Sans Thai exclusively. One typeface, many weights. Resist font pairing.
- **Do** follow the semantic risk color system consistently. Green/amber/red/critical patterns must be identical across all surfaces.
- **Do** use soft shadows (opacity 0.04–0.12) for elevation. Gentle separation, not dramatic contrast.
- **Do** reserve the warm accent (#d4a574) for ≤10% of any screen. Its rarity is the point.
- **Do** test all hierarchy levels with Thai text. Thai script demands generous line height (≥1.4 for body).
- **Do** use 150–250ms ease-out transitions for interactive states. Fast enough to feel responsive, slow enough to feel smooth.
- **Do** embrace density where it serves the workflow. Tables with many rows, panels with many labels—users need the data.
- **Do** use consistent component vocabulary. Same button shape, same form-control patterns, same icon style across all screens.

### Don't:
- **Don't** use generic SaaS dashboard templates. Avoid cold blue gradients, stock chart styling, and cookie-cutter layouts.
- **Don't** use bureaucratic government software patterns. Avoid dense, poorly-organized tables with cramped spacing and outdated visual language.
- **Don't** use consumer-app casual patterns. This handles sensitive personnel data—avoid playful patterns, excessive animation, or decorative flourishes.
- **Don't** use border-left or border-right greater than 1px as a colored accent stripe. Rewrite with full borders, background tints, or nothing.
- **Don't** use gradient text (background-clip: text with gradient background). Use solid colors. Emphasis via weight or size.
- **Don't** use glassmorphism decoratively. Blurs and glass cards should be rare and purposeful, or absent.
- **Don't** use tiny uppercase tracked eyebrows above every section. The 2023-era kicker is AI grammar. Choose a different cadence.
- **Don't** use numbered section markers (01 / 02 / 03) as default scaffolding. Numbers earn their place when order carries information.
- **Don't** animate CSS layout properties unless truly needed. Use transform and opacity for performance.
- **Don't** use display fonts in UI labels, buttons, or data. Noto Sans Thai carries everything.
- **Don't** reinvent standard affordances for flavor. Custom scrollbars, weird form controls, non-standard modals—avoid.
- **Don't** use heavy color or full-saturation accents on inactive states. Accent color is for active states only.
- **Don't** default to modals. Exhaust inline / progressive alternatives first.
