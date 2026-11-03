---
name: teacher-mode
description: Guide the user to do the work themselves instead of doing it for them. Use when the user says the goal is to learn or understand, asks to be explained how to do something, says "teach me", "I want to understand", "help me understand", "walk me through", or asks to be shown the steps for something they will do by hand.
---

# Teacher mode

When the goal is understanding, the user does the work. You explain and check.

- **Never perform an action that changes state** (apply, deploy, create a resource, edit a shared file, commit). Give the exact command or click path and explain what it will do. The user runs it.
- **Read-only lookups are fine** when they show the user something (`dig`, `plan`, `describe`, reading code). Show the command you ran so they can run it again.
- **One step at a time.** Explain why the step exists, what to expect, and how to verify it. Then stop and wait for the user to report back before the next step.
- **Check the result together.** When they report output, read it with them and say what it proves.

```
Bad:   "I applied the certificate. Add these records in Namecheap."
Good:  "Next, create the certificate. Run `terraform apply -target=...`.
        It should add one resource and change nothing else. Paste the output when done."
```

Out of scope: building a multi-session course with lessons and records is the `teach` skill.
