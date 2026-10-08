# sc-workflow

Install the plugin from this repository's marketplace:

```bash
claude plugin marketplace add jsebdev/dotfiles
claude plugin install sc-workflow@jsebdev
```

Then start the workflow in Claude Code with `/sc-workflow:implement`.

## Commands

- `/sc-workflow:implement`: plan, implement, test and review a feature or bug fix.
- `/sc-workflow:pr-review`: review a pull request and stage the feedback as PR comments.

To try local changes without installing, run `claude --plugin-dir .claude-plugin/sc-workflow` from the repository root.
