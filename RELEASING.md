# How to Cut a Release of Infinite Satchel

This project uses GitHub Actions to automatically build and attach a `.zip` file to each tagged release. Follow these steps whenever you’re ready to publish a new version.

---

## 1. Update Version Numbers
- Open **`InfiniteSatchel.toc`**
- Update the `## Version:` field (e.g., `0.1.1`)
- Optionally, update the **README.md** to reflect new features

---

## 2. Commit Changes

git add InfiniteSatchel.toc README.md
git commit -m "chore: bump version to 0.1.1"
git push origin dev

- Open a Pull Request from dev → main and merge.
- main should always match the latest release state.

---

## 3. Create a Tag

git checkout main
git pull origin main
git tag v0.1.1
git push origin v0.1.1

---

## 4. GitHub Actions Builds

- Pushing the tag triggers .github/workflows/release.yml
- Within ~1 minute, a new Release is created on GitHub
- The zip will be named:
  `InfiniteSatchel-v0.1.1.zip`

---

## 5. Share the Release

Point testers or CurseForge/Wago uploads to the `.zip` from the Release page

Notes

- Tags must start with `v` (e.g., `v0.1.1`)
- Do not tag commits directly on `dev` — always merge to `main` first
- Use semantic versioning:
  - `0.x.y` for early dev
  - `1.0.0` once stable/public
  - bump major (breaking), minor (features), patch (bugfixes)

---
