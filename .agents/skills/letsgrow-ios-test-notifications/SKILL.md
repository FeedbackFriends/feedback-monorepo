---
name: letsgrow-ios-test-notifications
description: Run the LetsGrow iOS notification test command.
---

From the monorepo root, run:

```bash
python3 ios-app/scripts/test-notifications.py --counts 0 1 2 99
```

For `smoke`, use `--counts 99` instead. Forward explicitly supplied runner options.
The command handles building and simulator setup. Do not perform separate Xcode,
build, setup, or investigation steps. Report the command's exit status and output.
