# Wiki Updates Changelog Schema

The wiki changelog Markdown should contain:

1. Front matter with `generated_at` and `synchronized_by` fields.
2. A heading `# Wiki Sync Summary` summarizing the scope.
3. A table `## Updated Pages` with columns `Page`, `Change Type`, `Source`. Each entry links to
   the wiki page and the source file in the main repository.
4. Optional section `## Notes` for additional commentary.

This structure allows downstream bots to append additional update details in predictable places.
