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
> **Status: operational.** Content synchronization and the regression
> fixtures described below are live, running on a daily schedule.

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

The regression signal lives on five `regression/*` branches, each testing a
different, deliberately distinct combination of API content against the same
current `code/common/`. None is the "correct" state the others deviate from —
each has its own expected finding count.

| Branch | API / Test definitions | What it tests |
|---|---|---|
| `regression/r4.3-api-templates` | Frozen at the **last published** (r4.3) Commonalities sample templates | Migration guide: findings accumulate as the **product** — together they describe what an already-published API repository must change to adopt the upcoming release. Growth here is expected, not a defect |
| `regression/commonalities-main-mirror` | Fresh, unsubstituted templates straight from Commonalities `main` | Faithful current-state mirror. Findings expected **near zero**; a new one is a real regression on the Commonalities or tooling side |
| `regression/qod-r4.1` | Real, published `QualityOnDemand` content (`source/r4.1`) | Whether a real, complex API sees the same migration signal as the artificial templates |
| `regression/device-roaming-status-r2.1` | Real, published `DeviceRoamingStatus` content (`source/r2.1`) | The explicit-subscription `Config`/`ConfigBase` migration path — `qod-r4.1`'s implicit-only session model never references the shared subscription `Config` schema at all |
| `regression/all-definitions-coverage` | Two artificial specs, purpose-built to reference every non-deprecated schema/response | Transitive coverage of `CAMARA_common.yaml`/`CAMARA_event_common.yaml` the other four branches leave untouched (the geometry family, phoneNumber-identified subscriptions) — a testing aid, not a community-facing artifact |

The pipeline lives in [`camaraproject/tooling`](https://github.com/camaraproject/tooling)
as the reusable workflow
[`.github/workflows/commonalities-regression-sync.yml`](https://github.com/camaraproject/tooling/blob/main/.github/workflows/commonalities-regression-sync.yml)
(jobs `Sync` and `Sweep`): it syncs `code/common/` from Commonalities `main`
onto this repository's `main`, cherry-picks that same commit onto every
`regression/*` branch, regenerates the mirror branch's templates, and sweeps
all branches for a fixture deviation. `main` itself is never swept — it is
the sync source, not a fixture target.

It is triggered by two callers: the thin
[`.github/workflows/commonalities-regression.yml`](https://github.com/camaraproject/tooling/blob/main/.github/workflows/commonalities-regression.yml)
(**Commonalities Regression** — daily schedule plus on-demand
`workflow_dispatch`, no logic of its own beyond dispatching), and tooling's
`validation-regression.yml`, which calls it with `force: true` on every
tooling push so a tooling change is regression-tested against this content
too.

Each branch commits its own `.regression/regression-expected.yaml` fixture
recording the findings already triaged and accepted. The sweep compares
actual findings against that fixture, so the actionable signal is a
**deviation**, not the raw finding list.

**Latest results:** [tooling → Actions → Commonalities Regression](https://github.com/camaraproject/tooling/actions/workflows/commonalities-regression.yml).

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
  stale. Recapture `.regression/regression-expected.yaml` (see below); no
  issue filed.

Note that a *missing* rule produces no finding, so the fixture comparison cannot
surface one. Spotting a changed Commonalities requirement that no rule covers yet
remains a manual read of the content changes.

### Recapturing a fixture

Follow tooling's
["Recapturing a fixture"](https://github.com/camaraproject/tooling/blob/main/validation/docs/regression-testing.md#recapturing-a-fixture)
— the runner and `--capture` mode are shared with `ReleaseTest`'s canary
branches, this repository is just a different `--repo` target, e.g.:

```
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/CommonalitiesTest \
    --capture regression/qod-r4.1 \
    --out /tmp/expected.yaml
```

Review `/tmp/expected.yaml`, then commit it as
`.regression/regression-expected.yaml` and push directly to the same
`regression/*` branch — no PR, as with any other change on these branches.

## State to preserve

* **All five `regression/*` branches are permanent** — each is a regression
  sweep target. Do not rename or delete any of them.
* **Every branch's `.regression/regression-expected.yaml` fixture is
  permanent.** Update it by recapture when a change is triaged as
  intentional; do not delete it to make a run pass.
* **`regression/r4.3-api-templates`'s API and test definitions are frozen**
  at the last published Commonalities release. Advance them only when
  Commonalities publishes a new release.
* **`main`'s own API definitions are frozen** — they are the source
  `regression/r4.3-api-templates` was cut from and are not re-synced; `main`
  continues to serve only as the `code/common/` sync source for every branch.
* The declared Commonalities release (`release-plan.yaml`) and the content of
  `code/common/` **move together** on every branch. Validation checks their
  consistency, so a mismatch is itself a finding.

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
