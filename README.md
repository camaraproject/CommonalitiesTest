<a href="https://github.com/camaraproject/CommonalitiesTest/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/CommonalitiesTest?style=plastic"></a>
<a href="https://github.com/camaraproject/CommonalitiesTest/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/CommonalitiesTest?style=plastic"></a>
<a href="https://github.com/camaraproject/CommonalitiesTest/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/CommonalitiesTest?style=plastic"></a>
<a href="https://github.com/camaraproject/CommonalitiesTest/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>

# CommonalitiesTest

> [!CAUTION]
> This repository is a test fixture, not an API repository. Its content is
> synchronized automatically from [camaraproject/Commonalities](https://github.com/camaraproject/Commonalities)
> and exists solely to run CAMARA API Validation against work-in-progress
> Commonalities content. Do not use it as a reference for how a real API
> repository should look, and do not consume its API definitions — they are
> deliberately held at mixed vintages, as described below.

> [!NOTE]
> **Status: being set up.** The repository has been created but the content
> synchronization and the regression fixtures described below are not in place
> yet. Until they are, the layout here is the unmodified CAMARA API repository
> template.

## Purpose

CommonalitiesTest gives [Commonalities](https://github.com/camaraproject/Commonalities)
and [tooling](https://github.com/camaraproject/tooling) a **standing regression
signal on unreleased content**. It answers two questions continuously, before
either project publishes anything:

1. **Is current Commonalities content clean** under the current validation ruleset?
2. **What would an existing API repository have to change** to adopt the upcoming
   Commonalities release?

Both are answered by validating a real API-repository layout populated from
Commonalities, rather than by reasoning about the guidelines in the abstract.

## How it works

The repository carries **two validation targets with deliberately opposite
purposes**. Neither is the "correct" state that the other deviates from.

| Target | API / Test definitions | `code/common/` + declared release | Expected findings |
|---|---|---|---|
| `main` | Frozen at the **last published** Commonalities release | Tracks the **upcoming** release | **Grows** over the release cycle |
| `regression/main-mirror` | Fresh from Commonalities `main` | Tracks the **upcoming** release | **Near zero** |

* **`main`** models a real, already-published API repository that bumps its
  declared Commonalities dependency and picks up the new common files without
  touching its own API definitions. The findings accumulating here are the
  product: taken together they are the **migration guide** from the last
  published release to the upcoming one. A growing finding count on `main` is
  expected, and is not a defect.
* **`regression/main-mirror`** is a faithful mirror of Commonalities `main` —
  definitions and common files both current. Here everything is meant to fit
  together, so a **new finding is a real regression** on either the
  Commonalities side or the tooling side, and is triaged as such.

A scheduled workflow in this repository polls Commonalities `main`. On a change
it opens (or amends) a sync pull request for `main`'s common files, and appends a
commit to the mirror branch. The two are updated independently — the mirror does
not wait on the sync PR being reviewed or merged.

Each target commits a `.regression/regression-expected.yaml` fixture recording
the findings already triaged and accepted. Tooling's validation regression
workflow compares actual findings against those fixtures, so the actionable
signal is a **deviation** from the fixture rather than the raw finding list.

## Validation ruleset

Validation here runs against **tooling's `main`**, not the stable release line.
New rules for the upcoming release are authored on tooling `main` and are not yet
in a stable ruleset; pinning the stable line would validate work-in-progress
content against a ruleset missing the very rules this repository exists to
exercise.

## Triaging a deviation

A deviation from a committed fixture resolves to exactly one of three outcomes.
The comparison does not pre-sort them — the judgement needs a reviewer who
understands both the rule's intent and the content's intent.

* **Commonalities defect** — the merged content is wrong. File against Commonalities.
* **Tooling defect** — the rule fired wrongly, or no longer matches a changed
  requirement. File against tooling.
* **Intentional change** — neither side is wrong and the fixture is simply
  stale. Recapture `.regression/regression-expected.yaml`; no issue filed.

Note that a *missing* rule produces no finding, so the fixture comparison cannot
surface one. Spotting a changed Commonalities requirement that no rule covers yet
remains a manual read of the content changes.

## State to preserve

* **`regression/main-mirror` is permanent** — it is a regression sweep target.
  Do not rename or delete it.
* **Both `.regression/regression-expected.yaml` fixtures are permanent.** Update
  them by recapture when a change is triaged as intentional; do not delete them
  to make a run pass.
* **`main`'s API and test definitions are frozen** at the last published
  Commonalities release. Advance them only when Commonalities publishes a new
  release.
* The declared Commonalities release and the content of `code/common/` **move
  together**. Validation checks their consistency, so bumping one without the
  other is itself a finding.

<!-- CAMARA:RELEASE-INFO:START -->
<!-- The following section is automatically maintained by the CAMARA project-administration tooling: https://github.com/camaraproject/project-administration -->

## Release Information

This repository is a test fixture and does not publish releases.

<!-- CAMARA:RELEASE-INFO:END -->

## Contributing

This repository is maintained by the Commonalities and tooling maintainers as
test infrastructure. It is not open for API contributions, and its content is not
hand-authored — changes arrive by synchronization from Commonalities.

An issue about a finding seen here belongs in
[Commonalities](https://github.com/camaraproject/Commonalities/issues) or
[tooling](https://github.com/camaraproject/tooling/issues), depending on the
triage outcome above.
