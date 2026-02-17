# Community Projects

[English](./README.md) | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md)

> Updated: 2026-02-17  
> Maintainer: Dujiao-Next Community

`community-projects` collects third-party contributions for the Dujiao-Next ecosystem, including templates, scripts, tools, and tutorials.
The goal is to help contributors share practical work and help users discover reusable community resources quickly.

## Directory Overview

- `scripts/`: Script projects (deployment scripts, migration scripts, automation scripts, etc.)
- `templates/`: Template projects (themes, page templates, email templates, etc.)
- `tools/`: Tool projects (CLI utilities, plugins, helper apps, visual tools, etc.)
- `wikis/`: Tutorial and guide content (how-to guides, best practices, troubleshooting notes, etc.)

## Accepted Contributions

Welcome submissions that are:

1. Related to Dujiao-Next ecosystem extensions
2. Open, reusable, and maintainable
3. Useful for real community scenarios

Not recommended:

1. Closed-source content without clear usage instructions
2. Generic projects unrelated to Dujiao-Next
3. Placeholder-only content without real implementation or docs

## Submission Conventions

Each project should be submitted in its own folder.
Naming recommendation:

- Lowercase with hyphens, for example: `payment-notify-helper`
- Avoid spaces, non-ASCII folder names, or special symbols

Recommended structure:

```text
community-projects/
  templates/
    your-project-name/
      README.md
      LICENSE
      src/ or docs/ ...
```

## Required Items

Each submitted project should include the following:

1. Open-source license
- A `LICENSE` file is required
- Recommended licenses: MIT / Apache-2.0 / GPL-3.0
- If third-party assets are used, document their license terms

2. Usage guide
- A project-level `README.md` is required
- At minimum include: overview, installation, configuration, usage example, FAQ
- State runtime prerequisites (Node.js / Go / database / OS) when needed

3. Maintainer information
- Author or maintainer identity (name or organization)
- Contact entry (optional, issue/discussion link recommended)
- Compatibility statement (supported Dujiao-Next versions)

## Recommended README Sections

1. Project introduction (what problem it solves)
2. Features
3. Installation and setup
4. Configuration
5. Usage tutorial (minimal runnable example)
6. FAQ
7. License
8. Changelog (optional)

## Suggested Submission Flow

1. Fork and clone this repository
2. Create your project folder under the correct category
3. Add `README.md` and `LICENSE`
4. Run local verification
5. Open a Pull Request and include:
- project purpose
- use cases
- usage notes
- compatibility version

## Review Criteria

Maintainers will focus on:

1. Documentation completeness (especially license and usage guide)
2. Reproducibility and practical usability
3. Relevance to Dujiao-Next ecosystem
4. No obvious infringement, sensitive, or non-distributable content

## Disclaimer

Projects under `community-projects` are provided by community contributors.
Quality, stability, and ongoing maintenance are owned by each contributor.
Please evaluate and test before production use.
