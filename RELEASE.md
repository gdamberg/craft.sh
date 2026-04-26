# Release Process

Releases are created by pushing a version tag. GitHub Actions runs shellcheck, then creates a GitHub release with `craft.sh` attached as a downloadable asset. Release notes are auto-generated from commits since the previous tag.

## Steps

**1. Bump the version in `craft.sh`:**
```bash
# Edit the VERSION line near the top of the file
readonly VERSION="x.y.z"
```

**2. Commit the bump:**
```bash
git add craft.sh
git commit -m "Bump version to x.y.z"
```

**3. Tag and push:**
```bash
git tag vx.y.z
git push origin main
git push origin vx.y.z
```

Before tagging, ensure the verification workflow (`.github/workflows/verification.yml`) is passing on `main` — it runs a syntax check, shellcheck, and a dry-run smoke test on every push.

The release workflow (`.github/workflows/release.yml`) triggers on the tag push and is self-contained — it runs the full verification suite (syntax check, shellcheck, dry-run smoke test) plus a version consistency check that verifies `VERSION` in `craft.sh` matches the tag. If any check fails the release is not created.

## Versioning

Follow [Semantic Versioning](https://semver.org):

- `PATCH` (x.y.**z**) — bug fixes and minor improvements
- `MINOR` (x.**y**.0) — new flags or features, backwards compatible
- `MAJOR` (**x**.0.0) — breaking changes to CLI interface or behaviour
