# Adding Your Own Vocabulary Set

This guide is for **teachers, parents, and other contributors** who want to add a custom word set to Vocabulary Practice. You do **not** need to install the app or write code. You will create a simple spreadsheet file and submit it through GitHub’s website.

After your submission is reviewed and merged, your set will appear in the app the next time a new version is released. Students can then find it using the **search bar** on the word set screen (for example, by searching your name or school).

---

## What you will do (overview)

1. Create a vocabulary file in Google Sheets (or Excel).
2. Save it as a CSV file with a specific name.
3. Copy the project on GitHub (called a **fork**).
4. Upload your file to the project.
5. Open a **pull request** (PR) so the team can review and add your set.

A **pull request** is a request to add your changes to the official app. Think of it like handing in an assignment for review before it goes into the final product.

---

## Before you start

### You will need

- A free [GitHub account](https://github.com/signup)
- A list of words, definitions, and grade levels
- About 20–30 minutes for your first submission

### Choose a set ID (important)

Every set needs a unique **set ID**: a short name using only **lowercase letters, numbers, and hyphens**.

**Good examples:**

- `ms-frizzle-1st-grade-week-1`
- `lincoln-3rd-grade-spring-2026`
- `room-12-science-words`

**Do not use:**

- Spaces (`ms frizzle week 1`)
- Uppercase letters (`Ms-Frizzle-Week-1`)
- The prefix `vocab-set-` (reserved for built-in sets)

Your **file name** must exactly match your set ID, plus `.csv`:

```
ms-frizzle-1st-grade-week-1.csv
```

---

## Step 1: Create your word list in Google Sheets

### Start from the template

1. Open the project on GitHub: [vocab-aloud-app](https://github.com/vtruong-systems/vocab-aloud-app).
2. Go to **data/vocabulary/community/**.
3. Open **`_template.csv`**.
4. Click the **Raw** button (or **Download**), then open the file in Google Sheets.

### Fill in the top section (metadata)

The lines at the top start with `#`. These describe your set. **Fill in every required line.**

| Line | Required? | Example |
|------|-----------|---------|
| `# set_id,...` | Yes | `ms-frizzle-1st-grade-week-1` |
| `# title,...` | Yes | `Ms. Frizzle — 1st Grade Week 1` |
| `# teacher,...` | Recommended | `Ms. Frizzle` |
| `# school,...` | Recommended | `Lincoln Elementary` |
| `# description,...` | Optional | `Weekly vocabulary for room 12` |
| `# theme,...` | Optional | `Science & Nature` |

**Why teacher and school matter:** students search for sets by teacher name, school, or set title in the app. The more you fill in, the easier it is to find your set.

### Add your words

Below the header row `Word,Category,Meaning,...`, add one row per word.

| Column | What to enter | Example |
|--------|---------------|---------|
| **Word** | The vocabulary word | `Gather` |
| **Category** | Subject area (see list below) | `Instructional Language` |
| **Meaning** | Kid-friendly definition | `To bring things together` |
| **Related Words** | Optional; not shown in app today | `collect assemble` |
| **Grade** | `Pre-K`, `K`, `1`, `2`, `3`, `4`, or `5` | `1` |
| **Difficulty** | `easy`, `medium`, or `hard` | `easy` |

**Allowed categories** (copy exactly, including capitalization):

- Communication & Discussion
- Directional Language
- Feelings & Emotions
- Instructional Language
- Learning & Research
- Mathematics
- Progress & Learning
- Punctuation
- Reading & Writing
- Scientific Thinking
- Sequence Words
- Thinking & Reasoning

### Tips for a good file

- Use **simple definitions** a child can understand.
- Avoid commas in definitions if possible. If you need a comma, wrap the whole cell in quotes when exporting.
- Include at least **one word** per set.
- Double-check spelling before you submit.

### Download your file

1. In Google Sheets: **File → Download → Comma Separated Values (.csv)**.
2. Rename the downloaded file to match your set ID, for example:  
   `ms-frizzle-1st-grade-week-1.csv`

Open the file in a plain text editor (Notepad, TextEdit) and confirm:

- The `# set_id,...` line matches your file name (without `.csv`).
- The word header row is present: `Word,Category,Meaning,Related Words,Grade,Difficulty`
- Your words appear below that row.

---

## Step 2: Fork the project on GitHub

If you do not have permission to edit the project directly, you need your **own copy** first. GitHub calls this a **fork**.

1. Sign in to [GitHub](https://github.com).
2. Open the main project page.
3. Click the **Fork** button (top right).
4. Leave the settings as default and click **Create fork**.

You now have your own copy under your GitHub username, for example:  
`https://github.com/YOUR-USERNAME/vocab-aloud-app`

---

## Step 3: Upload your CSV file

1. On **your fork**, open the folder:  
   **data → vocabulary → community**
2. Click **Add file → Upload files**.
3. Drag your CSV file into the upload area (or click **choose your files**).
4. At the bottom, in **Commit changes**:
   - **Title:** something like `Add ms-frizzle 1st grade week 1 vocabulary set`
   - **Description (optional):** your name, school, and grade level
5. Click **Commit changes**.

GitHub saves the file to your fork. It is not in the official app yet.

---

## Step 4: Open a pull request

A pull request asks the project maintainers to add your file to the official app.

1. After committing, GitHub may show a yellow banner: **“Compare & pull request”**. Click it.  
   If you do not see the banner:
   - Go to the **original** project (not your fork).
   - Click the **Pull requests** tab.
   - Click **New pull request**.
   - Click **compare across forks**.
   - Set **base repository** to the official repo, branch `main`.
   - Set **head repository** to **your fork**, branch `main`.
   - Click **Create pull request**.

2. Fill in the pull request:
   - **Title:** `Add vocabulary set: [your set title]`
   - **Description:** include:
     - Teacher name
     - School
     - Grade level
     - Anything we should know when reviewing

3. Click **Create pull request**.

You have now submitted your set for review.

---

## Step 5: What happens next

1. **Automated checks** run on your pull request. If you only uploaded the CSV file, one check may fail because an internal build file also needs updating. **That is normal** for community submissions — a maintainer can fix it before merging.
2. A maintainer **reviews** your words and metadata.
3. If something needs fixing, they may leave a comment on the pull request. You can upload a corrected CSV the same way (Step 3) on your fork; the pull request updates automatically.
4. Once approved and **merged**, your set is included in the next app release.
5. After users update the app, students can search for your set by **teacher name**, **school**, **title**, or **set ID**.

---

## Updating an existing set you submitted

1. Open **your fork** on GitHub.
2. Go to **data/vocabulary/community/** and click your CSV file.
3. Click the **pencil icon** (Edit this file).
4. Make your changes in the browser, or paste in updated content.
5. Click **Commit changes** at the bottom.

If you already have an open pull request, it updates automatically. If the set was already merged, repeat **Step 4** to open a new pull request.

---

## Quick checklist

Before you open a pull request, confirm:

- [ ] Set ID uses only lowercase letters, numbers, and hyphens
- [ ] Set ID does **not** start with `vocab-set-`
- [ ] File name is `{set_id}.csv` and matches `# set_id,...` in the file
- [ ] `# title,...` is filled in
- [ ] `# teacher,...` and `# school,...` are filled in (recommended)
- [ ] At least one word row is present
- [ ] Grade values are: Pre-K, K, 1, 2, 3, 4, or 5
- [ ] Difficulty values are: easy, medium, or hard
- [ ] Categories match the allowed list exactly

---

## Need help?

If GitHub feels overwhelming, you can:

- Ask a colleague who has used GitHub before to walk through Steps 2–4 with you, or
- Open a **GitHub Issue** on the project describing your set (teacher name, school, word list), and a maintainer can help create the file for you.

---

## Example file

```csv
# set_id,ms-frizzle-1st-grade-week-1
# title,Ms. Frizzle — 1st Grade Week 1
# teacher,Ms. Frizzle
# school,Lincoln Elementary
# description,Weekly vocabulary for room 12
# theme,Science & Nature
Word,Category,Meaning,Related Words,Grade,Difficulty
Gather,Instructional Language,To bring things together,collect assemble,1,easy
Species,Scientific Thinking,A group of similar living things that can reproduce,kind classification,4,hard
```

---

*Thank you for contributing vocabulary sets. Your words help more children practice and learn.*
