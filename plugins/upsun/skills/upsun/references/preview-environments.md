# Development in previews

Use this workflow for development on Upsun, including building and reviewing features, debugging, testing database migrations, and comparing performance. Preview environments let you develop and test with realistic data, share running changes for review, and recover from experiments by syncing from the parent.

## Establish the target and isolation

1. Resolve the project, production environment, intended parent, and target preview from platform metadata. Supply explicit project and environment IDs on remote commands.
2. Check inherited configuration and external connections before creating or refreshing the preview, so deployment hooks, workers, and tests cannot produce live side effects. Arrange test endpoints or disable the relevant payment, email, webhook, and similar integrations. Apply the project's sanitization and access controls to production-derived data, including after sync.
3. Create a dedicated preview from the environment whose data or behavior is needed, using the project's source integration workflow where applicable. Verify parent-data cloning is enabled and wait for deployment to finish.
4. Once isolated, use the preview for the authorized development work: implement and test changes, share them for review, SSH into containers, and run experiments with data changes, database recreation, diagnostics, and failure cases. Follow the skill's write-confirmation rules for destructive commands.

Record the deployed commit, relevant configuration, data baseline, and observations so the experiment can be reproduced. Preserve useful evidence before overwriting data or removing the preview.

Container logs under `/var/log` are not cloned or copied by data sync. Read them on the source environment when investigating its behavior, using the skill's production container-log exception where applicable. A preview produces its own logs. Platform activity logs are separate from these container logs.

## Sync and repeat

Use sync to refresh or recover a preview. Verify the direction every time: **parent into child**, with the preview as the command's target. Select what to synchronize explicitly:

| Selection | Effect | Use |
|---|---|---|
| `data` | Replaces child service and file data with the parent's | Refresh the baseline or recover after destructive testing |
| `code` | Merges parent code into the child; rebase is optional | Bring the experiment up to date |
| `resources` | Applies parent resource allocations to the child | Reproduce a capacity-dependent issue when justified |

Choose one of these alternatives after substituting verified identifiers and obtaining the required write confirmation:

```bash
# Refresh data only
upsun sync data -p PROJECT_ID -e PREVIEW_ID
```

Or refresh code and data together:

```bash
upsun sync code data -p PROJECT_ID -e PREVIEW_ID
```

Data sync overwrites preview-only changes. Preserve anything needed for review first. Code sync does not remove experimental commits; restore the intended revision deliberately or create a fresh preview when a clean code baseline is needed. Sync does not reset all environment settings or external systems.

Wait for completion, inspect the resulting deployment and data, and reapply sanitization and isolation controls as needed. Hooks may change the baseline, so verify what actually ran before repeating the experiment.

Check the installed CLI's `upsun sync --help` for version-sensitive options. See the [CLI sync reference](https://developer.upsun.com/cli/reference#environment-synchronize).

## Test a database migration

1. Start with relevant parent data in the preview and capture the initial schema and behavior.
2. Deploy the migration through the project's authorized Git workflow. If it runs in a deploy hook, exercise that path and inspect its logs.
3. Verify schema changes, data integrity, and application behavior in the preview. A completed deployment alone does not prove migration success.
4. Sync parent data back into the preview to repeat. Check whether hooks have already applied the migration and establish the intended starting state before rerunning or measuring it.

Use the application's actual migration setup. Do not assume pushing an unchanged commit or redeploying reruns a migration; check [hook execution and reuse](https://developer.upsun.com/docs/configure-apps/hooks/hooks-comparison).

## Compare performance

Measure before and after on the same preview, keeping workload, resources, and data baseline comparable. Many regressions and improvements can be demonstrated without production-sized infrastructure.

Match production resources only when the hypothesis depends on capacity or topology, such as a particular memory limit or concurrency across instances. Explain which resource matters and why the current preview cannot test it. Matching allocations does not reproduce production traffic, cache state, or external dependencies automatically.

Record the original allocation before a temporary increase and stay within the authorized budget and duration. Include `resources` in sync only when matching the parent is intentional. Data sync can also increase child disk allocations to fit the parent; inspect resources afterward. See [resource initialization and sync](https://developer.upsun.com/docs/manage-resources/resource-init).

## Clean up or retain for review

- Once results are captured and a temporary preview is no longer needed, remove it under the skill's confirmation rules. Verify the exact target and follow the source integration workflow for branch cleanup.
- If the developer needs the preview for review, keep it accessible and reduce temporary resource increases to a suitable review allocation. If downsizing would prevent reproduction, explain the dependency and remaining cost.
- Deactivation deletes environment-specific data and makes the environment inaccessible; it cannot preserve a runnable review environment. See [environment deactivation](https://developer.upsun.com/docs/environments/deactivate-environment).
- Report findings, the retained preview URL or ID, resource changes still in effect, and cleanup completed or remaining.
