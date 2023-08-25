# Red Hat SecureSign Timestamp Authority 

This repository holds the Red Hat fork of
`sigstore/timestamp-authority ` with modifications needed only for Red Hat.

## Mirroring upstream

The upstream repo, `sigstore/timestamp-authority ` is mirrored on the
`release-next` and `release-next-ci` branches, as well as all of the existing
release branches.

In order for mirroring to work correctly, you'll need to have two git remotes
for this repository.

- `upstream` pointing to `sigstore/timestamp-authority `
- `origin` pointing to `securesign/timestamp-authority ` (this repo)

When we are preparing to release a new version of Red Hat SecureSign/timestamp-authority,
we need to mirror the upstream repository and apply the patches and origin.
This is done using the `redhat/release/update-to-head.sh` script. When it runs,
the following steps are taken.

- The upstream is fetched and checked out as the `release-next` branch
- The `origin` remote `main` branch is pulled and Red Hat specific files from that branch are applied to the `release-next` branch
- The `release-next` branch is force pushed to the `origin` remote
- The `release-next` branch is duplicated to `release-next-ci`
- A timestamp file is added to `release-next-ci` branch
- The `release-next-ci` branch is force pushed to the `origin` remote
- A pull request is created (if it does not already exist) for this change, to trigger a CI run