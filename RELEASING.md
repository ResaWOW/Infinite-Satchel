# How to Cut a Release of Infinite Satchel

This project uses GitHub Actions to automatically build and attach a `.zip` file to each tagged release. Follow these steps whenever you’re ready to publish a new version.

---

## 1. Update Version Numbers
- Open **`InfiniteSatchel.toc`**
- Update the `## Version:` field (e.g., `0.1.1`)
- Optionally, update the **README.md** to reflect new features

---

## 2. Commit Changes
```bash
git add InfiniteSatchel.toc README.md
git commit -m "chore: bump version to 0.1.1"
git push origin dev
