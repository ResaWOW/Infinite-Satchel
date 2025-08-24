# How to Cut a Release of Infinite Satchel

This project uses GitHub Actions to automatically build and attach a `.zip` file to each tagged release. Follow these steps whenever you’re ready to publish a new version.

---

## 0. Prep
- Ensure all work is merged into `dev`.
- Review `CHANGELOG.md` and add notes under **[Unreleased]** for anything missing.

---

## 1. Update Version Numbers
- Open `InfiniteSatchel.toc`
- Update the `## Version:` field (e.g., `0.1.1`)
- Save the file

---

## 2. Finalize the Changelog
1) Open `CHANGELOG.md`  
2) Under **[Unreleased]**, make sure changes are grouped under headings (`Added`, `Changed`, `Fixed`, etc.)  
3) Create a new section **above** Unreleased:

    ## [0.1.1] - YYYY-MM-DD

    Move the Unreleased entries into this new section and replace the date with today’s date.

4) Leave an empty **[Unreleased]** section for future changes.

---

## 3. Commit Changes to `dev`
    git add InfiniteSatchel.toc CHANGELOG.md
    git commit -m "chore(release): 0.1.1"
    git push origin dev

- Open a Pull Request from `dev` → `main` and merge.
- `main` should always match the latest release state.

---

## 4. Create a Tag on `main`
    git checkout main
    git pull origin main
    git tag v0.1.1
    git push origin v0.1.1

This triggers `.github/workflows/release.yml`.

---

## 5. Verify the GitHub Release
- Go to **Releases** on GitHub.
- Confirm a new release exists with the attached zip:

    InfiniteSatchel-v0.1.1.zip

- (Optional) Edit the release and paste the **0.1.1** section from `CHANGELOG.md` into the release notes.

---

## 6. Share
- Share the Release page link or the `.zip` file.
- If publishing to CurseForge/Wago, upload the same zip and copy the changelog notes.

---

## Versioning Notes
- Tags must start with `v` (e.g., `v0.1.1`).
- Do not tag commits directly on `dev` — always merge to `main` first.
- Use Semantic Versioning:
  - `0.x.y` for early dev
  - `1.0.0` once stable/public
  - bump **MAJOR** (breaking), **MINOR** (features), **PATCH** (fixes)

---

## Quick Checklist
- [ ] `InfiniteSatchel.toc` version updated  
- [ ] `CHANGELOG.md` updated: move **[Unreleased]** → new version section with today’s date  
- [ ] PR merged: `dev` → `main`  
- [ ] Tag pushed: `vX.Y.Z`  
- [ ] GitHub release zip auto-generated  
- [ ] Release notes pasted from changelog (optional)
