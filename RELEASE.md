# Release Process

Releases are created by pushing a version tag. GitHub Actions runs the verification suite, creates a GitHub release with `craft.sh` attached as a downloadable asset, auto-generates release notes from commits since the previous tag, and updates the Homebrew formula.

## Steps

**1. Bump the version in `craft.sh`:**
```bash
# Edit the VERSION line near the top of the file
readonly VERSION="x.y.z"
```

**2. Commit and merge to main:**
```bash
git add craft.sh
git commit -m "Bump version to x.y.z"
git push origin main
```

> The tag must be pushed after main is up to date — the workflow checks out main and verifies that `VERSION` in `craft.sh` matches the tag.

**3. Tag and push:**
```bash
git tag x.y.z
git push origin x.y.z
```

**4. Done.**

The release workflow automatically:
- Runs the full verification suite (syntax check, shellcheck, dry-run smoke test)
- Verifies `VERSION` in `craft.sh` matches the tag
- Creates the GitHub release with `craft.sh` as a downloadable asset
- Updates `Formula/craft-sh.rb` with the correct URL and SHA256 and pushes the commit to main

If any check fails, the release is not created.

## Versioning

Follow [Semantic Versioning](https://semver.org):

- `PATCH` (x.y.**z**) — bug fixes and minor improvements
- `MINOR` (x.**y**.0) — new flags or features, backwards compatible
- `MAJOR` (**x**.0.0) — breaking changes to CLI interface or behaviour
