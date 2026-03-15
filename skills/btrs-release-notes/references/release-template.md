# Release Template Reference

Additional guidance for writing high-quality release notes. The main SKILL.md covers the process; this file provides writing guidance.

## Writing Style for Release Notes

Release notes are read by developers, QA, project managers, and sometimes customers. Write accordingly:

- **Features**: Lead with the user-facing benefit, then the technical detail. "Users can now filter by date range" not "Added DateRangePicker component".
- **Bug fixes**: Describe what was broken from the user's perspective, then what was fixed. "Fixed crash when opening files with special characters" not "Escaped regex in file parser".
- **Breaking changes**: Be very specific about what action the reader needs to take. Include exact migration steps when possible.
- **Highlights**: Write these last, after you've categorized everything. Pick the 2-3 things that matter most.

## Grouping Related Changes

Multiple commits or MRs often contribute to a single logical change. Group them:

- If 5 commits all touch the same feature, they're one "Feature" entry
- If an MR adds a feature and a follow-up MR fixes a bug in it, combine them under "Features" with a note about the fix
- Infrastructure changes that support a feature should be mentioned under the feature, not separately

## When Categories Are Empty

Omit empty categories entirely. Don't write "## Breaking Changes\n\nNone." — just leave out the section. The absence communicates that there are none.

## Handling Ambiguous Changes

Some changes don't fit neatly into one category:

- A refactor that also fixes a bug → **Bug Fixes** (the fix is what matters to the reader)
- A performance improvement with a new API → **Features** if user-facing, **Improvements** if internal
- A dependency update that fixes a security vulnerability → **Bug Fixes** with a note about the security aspect
- Test-only changes → Omit unless they're significant (e.g., new test infrastructure). Tests supporting a feature should be mentioned alongside the feature entry.
