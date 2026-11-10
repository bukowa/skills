---
description: Cognitive Ergonomics & Low-Load Table Formatting Rule
trigger: always_on
---

# COGNITIVE ERGONOMICS & LOW-LOAD TABLE RULE
**(MANDATORY FOR ALL STATUS UPDATES, BUG LISTS, SUMMARIES & PLANS)**

Format every diagnostic list, bug report, status update, or multi-step plan into 4-column Markdown tables governed by six empirical laws:

1. **Cowan’s 4-Chunk Limit (2001) & Trick & Pylyshyn’s Subitizing Law (1994):** Never output prose walls or flat tables >4 rows. Group items into titled Waves of **3–4 rows max** (subitized at 40–100 ms/item) while showing all waves to prevent Zeigarnik/Ovsiankina open-loop tension.
2. **Treisman’s Pre-Attentive Tags (1980) & Arnsten’s PFC Stress Law (2009):** Use exact columns: `| Area | What Changed / Broken | Why / Details (1 Simple Fact) | Status / Effort |`. Anchor `Area` with 1 concrete icon + 1 bold word (`📁 **Files**`) for <50 ms parallel pop-out. Ban threat icons (`🔴, ⚠️, 💥`) that trigger amygdala hijack. In `Status / Effort`, use **`✅ Done`** for completed items, and the Calm Executive Palette for pending work: `🟢 **Quick**`, `🔵 **Logic**`, `🟣 **Deep**`.
3. **Kintsch’s 1-Proposition Rule (1974) & Rayner’s Perceptual Span (1998):** Each cell must state **1 single fact in 4–6 words** (zero line wrapping, read in 2–3 fixations).
4. **Gibson’s SVO Dependency Minimization (1998) & Yngve’s Depth Law (1960):** Write `Why / Details` in strict Subject–Verb–Object order (`App only checks opened files.`) with zero nested clauses (DD = 1).
5. **Paivio’s Dual-Coding Concreteness (1971), Brysbaert’s Lexicon (2014) & Gigerenzer’s Natural Frequencies (1995):** Use physical everyday words (`file, name, link, sound`) decoded in ~180 ms. Use bold natural frequencies (`**24 of 28**`) **only when natural counts or ratios exist** (e.g. test results, batch counts); never force or invent artificial numbers for qualitative issues or single items. Never use double-negative counts (`0 of 63 fail`); state positive completion (`**63 of 63** tests pass`).
6. **Sweller’s Split-Attention Ban (1988), Ivanova’s MD-Network Law (2020) & Grice’s Quantity Maxim (1975):** Ban all file paths, line numbers, and code tokens from tables. Never add a redundant "How to Fix" column.

**Required Output Template:**
**Wave 1: [Short Category Name]**
| Area | What Changed / Broken | Why / Details (1 Simple Fact) | Status / Effort |
| :--- | :--- | :--- | :--- |
| 📁 **Files** | Audio bank loader fails | App guesses wrong file names. | 🟢 **Quick** |
| 🧪 **Tests** | **63 of 63** test cases pass | All test suites run cleanly. | ✅ **Done** |
