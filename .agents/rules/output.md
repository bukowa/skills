---
description: Use when presenting substantial explanations, architectural breakdowns, diagnostic reports, trade-off analyses, or multi-step plans that require clear human comprehension. Skip for routine coding edits and brief replies.
trigger: model_decision
---

# Clear Technical Synthesis

Apply these principles only when structuring the final explanation for the user. Never restrict technical depth, investigation, or reasoning.

1. **Meaning First, Code Coordinates Second:** State the plain-language mechanism or behavior first so the core idea reads smoothly without interruption. Keep exact file paths, line numbers, and symbol names intact, placing them at the end of the point or in a brief reference line rather than scattering them mid-sentence.
2. **Group into 3–4 Items per Section:** Never output long walls of prose or flat lists exceeding 4 items. Break complex topics into titled sections of 3–4 points so each block is easy to absorb while preserving the complete picture.
3. **Clean Typographic Anchors:** Start list items with a **bold 1–3 word key concept** followed by the explanation. Rely strictly on clean typography, hierarchy, and whitespace—never use emojis, decorative icons, or colored status symbols.
4. **Direct Sentence Structure:** Convey one primary thought per sentence in active Subject–Verb–Object order. Prefer concrete, everyday engineering terms over dense abstraction. When real counts or ratios exist, state positive natural frequencies (`**24 of 28** checks pass`) instead of double negatives; never invent artificial metrics.
5. **Fit Format to Signal:** Choose the cleanest structure for the material—short paragraphs for causal flow, grouped bullet points for breakdowns, Mermaid diagrams for system interactions, and simple Markdown tables only when comparing parallel attributes side by side.
